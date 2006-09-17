class Promoter < ActiveRecord::Base

  validate :not_blank
  
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

  def not_blank
    if (name.blank? and email.blank? and phone.blank?)
      errors.add("name, email, and phone cannot all be blank")
    end
  end
  
  def to_s
    "<Promoter #{id} #{name} #{email} #{phone}>"
  end

end
