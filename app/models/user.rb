class User < ActiveRecord::Base

  acts_as_authentic do |config|
    config.validates_length_of_email_field_options :within => 6..72, :allow_nil => true, :allow_blank => true
    config.validates_format_of_email_field_options :with => Authlogic::Regex.email, 
                                                   :message => I18n.t('error_messages.email_invalid', :default => "should look like an email address."),
                                                   :allow_nil => true,
                                                   :allow_blank => true
    config.validates_length_of_password_field_options  :minimum => 4, :allow_nil => true, :allow_blank => true
    config.validates_length_of_password_confirmation_field_options  :minimum => 4, :allow_nil => true, :allow_blank => true
  end

  has_and_belongs_to_many :roles
  has_many :events, :foreign_key => "promoter_id"

  def User.find_by_info(name, email = nil, phone = nil)
    if !name.blank?
      User.find_by_name(name)
    else
      User.find(
        :first, 
        :conditions => ["(email = ? and email <> '' and email is not null) or (phone = ? and phone <> '' and phone is not null)", 
                        email, phone]
      )
    end
  end
  
  def User.find_by_name(name)
    User.find(
      :first, 
      :conditions => ["trim(concat(first_name, ' ', last_name)) = ?", name]
    )
  end
  
  def email_with_name
    "#{name} <#{email}>"
  end

  def administrator?
    roles.any? { |role| role.name == "Administrator" }
  end

  def promoter?
    roles.any? { |role| role.name == "Promoter" }
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  def name
    Person.full_name(first_name, last_name)
  end

  # Tries to split +name+ into +first_name+ and +last_name+
  # TODO Handle name, Jr.
  # This looks too complicated …
  def name=(value)  
    if value.blank?
      self.first_name = ''
      self.last_name = ''
      return
    end

    if value.include?(',')
      parts = value.split(',')
      if parts.size > 0
        self.last_name = parts[0].strip
        if parts.size > 1
          self.first_name = parts[1..(parts.size - 1)].join
          self.first_name.strip!
        end
      end
    else
      parts = value.split(' ')
      if parts.size > 0
        self.first_name = parts[0].strip
        if parts.size > 1
          self.last_name = parts[1..(parts.size - 1)].join
          self.last_name.strip!
        end
      end
    end
  end
  
  # Name. If +name+ is blank, returns email and phone
  def name_or_contact_info
    if name.blank?
      [email, phone].join(', ')
    else
      name
    end
  end

  # All contact information cannot be blank
  def blank?
    name.blank? && email.blank? && phone.blank?
  end
  
  # Cannot have promoters with duplicate contact information
  def unique_info
    user = User.find_by_info(name, email, phone)
    if user && user != self
      errors.add("existing user with name '#{name}'")
    end
  end
end
