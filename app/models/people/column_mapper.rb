module People
  # 'club' ...this is often team in USAC download. How handle? Use club for team if no team? and if both, ignore club?
  #  'NCCA club' ...can have this in addition to club and team. should team be many to many?
  class ColumnMapper < Tabular::ColumnMapper
    MAP = {
      "team"                                   => :team_name,
      "Cycling Team"                           => :team_name,
      "club"                                   => :club_name,
      "ncca club"                              => :ncca_club_name,
      "fname"                                  => :first_name,
      "lname"                                  => :last_name,
      "f_name"                                 => :first_name,
      "l_name"                                 => :last_name,
      "FirstName"                              => :first_name,
      "first name"                             => :first_name,
      "LastName"                               => :last_name,
      "last name"                              => :last_name,
      "AAA Last Name"                          => :last_name,
      "Birth date"                             => :date_of_birth,
      "Birthdate"                              => :date_of_birth,
      "dob"                                    => :date_of_birth,
      "address"                                => :street,
      "Address1_Contact address"               => :street,
      "Address2_Contact address"               => :street,
      "address1"                               => :street,
      "City_Contact address"                   => :city,
      "State_Contact address"                  => :state,
      "Zip_Contact address"                    => :zip,
      "Phone"                                  => :home_phone,
      "DayPhone"                               => :home_phone,
      "cell/fax"                               => :cell_fax,
      "cell"                                   => :cell_fax,
      "e-mail"                                 => :email,
      "category"                               => :road_category,
      "road cat"                               => :road_category,
      "Cat."                                   => :road_category,
      "cat"                                    => :road_category,
      "USCF Category"                          => :road_category,
      "track cat"                              => :track_category,
      "cross cat"                              => :ccx_category,
      "ccx cat"                                => :ccx_category,
      "mtn cat"                                => :mtb_category,
      "XC"                                     => :mtb_category,
      "dh cat"                                 => :dh_category,
      "dh"                                     => :dh_category,
      "number"                                 => :road_number,
      "WSBA #"                                 => :road_number,
      "mtb #"                                  => :xc_number,
      "singlespeed"                            => :singlespeed_number,
      "ss"                                     => :singlespeed_number,
      "ss #"                                   => :singlespeed_number,
      "Membership No"                          => :license,
      "license#"                               => :license,
      "date joined"                            => :member_from,
      "exp date"                               => :member_usac_to,
      "expiration date"                        => :member_usac_to,
      "card"                                   => :print_card,
      "sex"                                    => :gender,
      "What is your occupation? (optional)"    => :occupation,
      "Suspension"                             => :status,   # e.g. "SUSPENDED - Contact USA Cycling"
      "Interests"                              => :notes,
      "Donation"                               => :notes,
      "Singlespeed"                            => :notes,
      "Tandem"                                 => :notes
    }

    def map(key)
      return nil if is_blank?(key) || !person_instance.respond_to?(key)
      MAP[key] || symbolize(key)
    end


    private

    def person_instance
      @person_instance ||= Person.new
    end
  end
end
