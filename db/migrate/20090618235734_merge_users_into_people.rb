class MergeUsersIntoPeople < ActiveRecord::Migration
  def self.up
    change_table :people do |t|
      t.string    :crypted_password, :null => true
      t.string    :password_salt, :null => true
      t.string    :persistence_token, :null => false
      t.string    :single_access_token, :null => true
      t.string    :perishable_token, :null => true
      t.integer   :login_count,         :null => false, :default => 0
      t.integer   :failed_login_count,  :null => false, :default => 0
      t.datetime  :last_request_at
      t.datetime  :current_login_at
      t.datetime  :last_login_at
      t.string    :current_login_ip
      t.string    :last_login_ip
    end
    
    add_index :people, :email, :unique => true

    User.find(:all) do |user|
      person = People.find_by_name(user.name)
      if person
        person.email = user.email
        person.home_phone = user.phone
        person.crypted_password = user.crypted_password
        person.password_salt = user.password_salt
        person.single_access_token = user.single_access_token
        person.persistence_token = user.persistence_token
      else
        Person.create!(
          :email => user.email,
          :home_phone => user.phone,
          :crypted_password => user.crypted_password,
          :password_salt => user.password_salt,
          :single_access_token => user.single_access_token,
          :persistence_token => user.single_access_token
        )
      end
    end
    
    rename_table :user_sessions, :person_sessions
    rename_table :user_roles, :person_roles
    remove_table :users
  end

  def self.down
    change_table :racers do |t|
      t.remove :crypted_password
      t.remove :password_salt
      t.remove :persistence_token
      t.remove :single_access_toke
      t.remove :perishable_token
      t.remove :login_count
      t.remove :failed_login_count
      t.remove :last_request_at
      t.remove :current_login_at
      t.remove :last_login_at
      t.remove :current_login_ip
      t.remove :last_login_ip
    end
  end
end

create table `people` (
  `id` int(11) not null auto_increment,
  `first_name` varchar(64) default null,
  `last_name` varchar(255) default null,
  `city` varchar(128) default null,
  `date_of_birth` date default null,
  `license` varchar(64) default null,
  `notes` text,
  `state` varchar(64) default null,
  `team_id` int(11) default null,
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  `cell_fax` varchar(255) default null,
  `ccx_category` varchar(255) default null,
  `dh_category` varchar(255) default null,
  `email` varchar(255) default null,
  `gender` char(2) default null,
  `home_phone` varchar(255) default null,
  `mtb_category` varchar(255) default null,
  `member_from` date default null,
  `occupation` varchar(255) default null,
  `road_category` varchar(255) default null,
  `street` varchar(255) default null,
  `track_category` varchar(255) default null,
  `work_phone` varchar(255) default null,
  `zip` varchar(255) default null,
  `member_to` date default null,
  `print_card` tinyint(1) default '0',
  `print_mailing_label` tinyint(1) default '0',
  `ccx_only` tinyint(1) not null default '0',
  `updated_by` varchar(255) default null,
  `bmx_category` varchar(255) default null,
  `wants_email` tinyint(1) not null default '1',
  `wants_mail` tinyint(1) not null default '1',
  `volunteer_interest` tinyint(1) not null default '0',
  `official_interest` tinyint(1) not null default '0',
  `race_promotion_interest` tinyint(1) not null default '0',
  `team_interest` tinyint(1) not null default '0',
  `created_by_id` int(11) default null,
  `created_by_type` varchar(255) default null,
  `member_usac_to` date default null,
  primary key (`id`),
  key `idx_last_name` (`last_name`),
  key `idx_first_name` (`first_name`),
  key `idx_team_id` (`team_id`),
  key `index_racers_on_member_to` (`member_to`),
  key `index_racers_on_member_from` (`member_from`),
  constraint `racers_team_id_fk` foreign key (`team_id`) references `teams` (`id`)
) engine=innodb default charset=utf8;
