class MergePromotersIntoUsers < ActiveRecord::Migration

  class Promoter < ActiveRecord::Base; end

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
  end

  def self.up
    User.reset_column_information
    execute "alter table events drop foreign key events_promoters_id_fk"

    Promoter.find(:all).each do |promoter|
      user = User.find_or_create_by_email(promoter.email)
      user.old_name = promoter.name
      user.save!
      execute "update events set promoter_id = #{user.id} where promoter_id = #{promoter.id}"
    end

    User.find(:all, :conditions => "old_name != ''").each do |user|
      first_name = user.old_name.split(" ").first
      last_name = user.old_name.split(" ").last
      user.first_name = first_name unless first_name == last_name
      user.last_name = last_name
      say "User #{user.first_name} #{user.last_name}"
      user.save!
    end
    
    execute "update users set crypted_password = '', persistence_token = '' where last_name = 'System'"
    execute "alter table events add constraint events_promoters_id_fk foreign key (promoter_id) references users (id) on delete set null"

    change_table :users do |t|
      t.remove :old_name
    end
    drop_table :promoters
  end
end
