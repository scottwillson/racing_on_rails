class User < ActiveRecord::Base

  acts_as_authentic

  has_and_belongs_to_many :roles

  def email_with_name
    "#{name} <#{email}>"
  end

  def administrator?
    roles.any? { |role| role.name == "Administrator" }
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end
end
