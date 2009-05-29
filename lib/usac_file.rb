#compares current members to USAC database for current year
#updates member_usac_to column to 12/31/{year}

class UsacFile
  
  attr_accessor :members_list
  
  USAC_SITE = "www.usacycling.org"
  REGION_FILES = {
    "Central" => "ct",
    "Mid-Atlantic" => "ma",
    "Mountain" => "mt",
    "North Atlantic" => "na",
    "North Central" => "nc",
    "North West" => "nw",
    "South Central" => "sc",
    "South East" => "se",
    "South West" => "sw",
    "West" => "we",
    "Wisconsin" => "wisc",
    "Complete" => "all"
  }
  
  #prefix each file with common filename hooey
  REGION_FILES.each_pair do |key,value| 
    REGION_FILES[key] = "/promoters/wp_p_uscf_" + value + ".csv"
  end
  
  def initialize(user='promo', pword='races')
    Net::HTTP.start(USAC_SITE) do |http|
      req = Net::HTTP::Get.new(REGION_FILES[ASSOCIATION.usac_region])
      req.basic_auth user, pword
      response = http.request(req)
      
      #parses out the data into a 2D array with other properties (such as column referencing like hashes)
      @members_list = FasterCSV.parse(response.body, {:col_sep => ",", :quote_char => "?", :headers => true})
      self.clean_headers
    end
  end
    
    #cleans up the headers so we can make clean column references
  def clean_headers
    @members_list.headers.each do |head|
      head.lstrip!
      head.downcase!
      head.sub!(/ /,"_") #spaces replaced with underscore
    end
  end
    
    #assumes USAC database contains current year's members only, all licenses good until end of this year
  def update_racers
    expir_date = Date.new(Date.today.year, 12, 31) 
    racers_updated = []
    @members_list.each {|memusac|
      #get the parameters in a nice format
      license = memusac["license#"].to_i.to_s #strips off leading zeros, consistent with our db
      full_name = memusac["first_name"].to_s + " " + memusac["last_name"].to_s #as specified by find method used below
      
      #Look for the racer. License # is most reliable (e.g. we only have short first name)
      #but we may not have their USAC License # yet, so also look by full name
      r = Racer.find_by_license(license)
      dups = Racer.find_all_by_name_or_alias(memusac["first_name"], memusac["last_name"])
      first_dup = dups.first unless dups.first.nil?
      if r.nil?
        r = Racer.find_by_name(full_name)
        r ||= first_dup
      else
        #we found someone by license. 
        if r != first_dup #the name USAC has does not match Racer name or alias
          #Let's make an alias with their name at USAC. Helps with importing results
          begin
            Alias.create!(:name => full_name, :racer => r)
          rescue Exception => e
            Rails.logger.warn("Could not create alias #{full_name} for racer #{r.name} with license #{r.license}")
          end
            
        end
      end
      
      unless r.nil? #we found somebody
          if r.license && r.license.match(/\d+/) && r.license != license
            #person has a license, but not this one. we must have the wrong person or other confusion.
            Rails.logger.warn("Had racer #{r.name} with license #{r.license} but did not match USAC license #{license} for #{memusac["first_name"]} #{memusac["last_name"]}")
          else 
            #Either the license # matches or we didn't get this data from the member. Either way, safe to overwrite it
            r.license = license
            r.member_usac_to = expir_date
            racers_updated.push(r) if r.save!
          end
      end
    }
    
    Rails.logger.info("#{racers_updated.length} racers were updated with a USAC expiration date of #{expir_date} ")
    return racers_updated
  end
  
end