class Promoter < ActiveRecord::Base

  validate :not_blank, :unique_info
  
  has_many :events
  
  def Promoter.find_by_info(name, email = nil, phone = nil)
    if !name.blank?
      return Promoter.find_by_name(name)
    else
      return Promoter.find(
        :first, 
        :conditions => ["(email = ? and email <> '' and email is not null) or (phone = ? and phone <> '' and phone is not null)", 
                        email, phone]
      )
    end
  end
  
  def name
    self[:name] || ''
  end
  
  def name_or_contact_info
    if name.blank?
      [email, phone].join(', ')
    else
      name
    end
  end

  def not_blank
    if (name.blank? and email.blank? and phone.blank?)
      errors.add("name, email, and phone cannot all be blank")
    end
  end
  
  def unique_info
    promoter = Promoter.find_by_info(name, email, phone)
    if promoter && promoter != self
      errors.add("existing promoter with name '#{name}'")
    end
  end
  
  def to_s
    "<Promoter #{id} #{name} #{email} #{phone}>"
  end

end
