create table `aliases` (
  `id` int(11) not null auto_increment,
  `alias` varchar(255) default null,
  `name` varchar(255) default null,
  `person_id` int(11) default null,
  `team_id` int(11) default null,
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  primary key (`id`),
  unique key `idx_name` (`name`),
  key `idx_id` (`alias`),
  key `idx_racer_id` (`person_id`),
  key `idx_team_id` (`team_id`),
  constraint `aliases_person_id` foreign key (`person_id`) references `people` (`id`) on delete cascade,
  constraint `aliases_team_id_fk` foreign key (`team_id`) references `teams` (`id`) on delete cascade
) engine=innodb default charset=utf8;

create table `bids` (
  `id` int(11) not null auto_increment,
  `name` varchar(255) not null,
  `email` varchar(255) not null,
  `phone` varchar(255) not null,
  `amount` int(11) not null,
  `approved` tinyint(1) default null,
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  primary key (`id`)
) engine=innodb default charset=utf8;

create table `categories` (
  `id` int(11) not null auto_increment,
  `position` int(11) not null default '0',
  `name` varchar(64) not null,
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  `parent_id` int(11) default null,
  `ages_begin` int(11) default '0',
  `ages_end` int(11) default '999',
  `friendly_param` varchar(255) not null,
  primary key (`id`),
  unique key `categories_name_index` (`name`),
  key `parent_id` (`parent_id`),
  key `index_categories_on_friendly_param` (`friendly_param`),
  constraint `categories_categories_id_fk` foreign key (`parent_id`) references `categories` (`id`) on delete cascade
) engine=innodb default charset=utf8;

create table `competition_event_memberships` (
  `id` int(11) not null auto_increment,
  `competition_id` int(11) not null,
  `event_id` int(11) not null,
  `points_factor` float default '1',
  primary key (`id`),
  key `index_competition_event_memberships_on_competition_id` (`competition_id`),
  key `index_competition_event_memberships_on_event_id` (`event_id`),
  constraint `competition_event_memberships_competitions_id_fk` foreign key (`competition_id`) references `events` (`id`) on delete cascade,
  constraint `competition_event_memberships_events_id_fk` foreign key (`event_id`) references `events` (`id`) on delete cascade
) engine=innodb default charset=utf8;

create table `discipline_aliases` (
  `discipline_id` int(11) not null default '0',
  `alias` varchar(64) not null default '',
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  key `idx_alias` (`alias`),
  key `idx_discipline_id` (`discipline_id`),
  constraint `discipline_aliases_disciplines_id_fk` foreign key (`discipline_id`) references `disciplines` (`id`) on delete cascade
) engine=innodb default charset=utf8;

create table `discipline_bar_categories` (
  `category_id` int(11) not null default '0',
  `discipline_id` int(11) not null default '0',
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  unique key `discipline_bar_categories_category_id_index` (`category_id`,`discipline_id`),
  key `idx_category_id` (`category_id`),
  key `idx_discipline_id` (`discipline_id`),
  constraint `discipline_bar_categories_disciplines_id_fk` foreign key (`discipline_id`) references `disciplines` (`id`) on delete cascade,
  constraint `discipline_bar_categories_categories_id_fk` foreign key (`category_id`) references `categories` (`id`) on delete cascade
) engine=innodb default charset=utf8;

create table `disciplines` (
  `id` int(11) not null auto_increment,
  `name` varchar(64) not null default '',
  `bar` tinyint(1) default null,
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  `numbers` tinyint(1) default '0',
  primary key (`id`),
  unique key `index_disciplines_on_name` (`name`)
) engine=innodb default charset=utf8;

create table `duplicates` (
  `id` int(11) not null auto_increment,
  `new_attributes` text,
  primary key (`id`)
) engine=innodb default charset=utf8;

create table `duplicates_people` (
  `person_id` int(11) default null,
  `duplicate_id` int(11) default null,
  unique key `index_duplicates_racers_on_racer_id_and_duplicate_id` (`person_id`,`duplicate_id`),
  key `index_duplicates_racers_on_racer_id` (`person_id`),
  key `index_duplicates_racers_on_duplicate_id` (`duplicate_id`),
  constraint `duplicates_people_person_id` foreign key (`person_id`) references `people` (`id`) on delete cascade,
  constraint `duplicates_racers_duplicates_id_fk` foreign key (`duplicate_id`) references `duplicates` (`id`) on delete cascade
) engine=innodb default charset=utf8;

create table `events` (
  `id` int(11) not null auto_increment,
  `parent_id` int(11) default null,
  `city` varchar(128) default null,
  `date` date default null,
  `discipline` varchar(32) default null,
  `flyer` varchar(255) default null,
  `name` varchar(255) default null,
  `notes` varchar(255) default '',
  `sanctioned_by` varchar(255) default null,
  `state` varchar(64) default null,
  `type` varchar(32) default null,
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  `flyer_approved` tinyint(1) not null default '0',
  `cancelled` tinyint(1) default '0',
  `notification` tinyint(1) default '1',
  `number_issuer_id` int(11) default null,
  `first_aid_provider` varchar(255) default '-------------',
  `pre_event_fees` float default null,
  `post_event_fees` float default null,
  `flyer_ad_fee` float default null,
  `prize_list` varchar(255) default null,
  `velodrome_id` int(11) default null,
  `time` varchar(255) default null,
  `instructional` tinyint(1) default '0',
  `practice` tinyint(1) default '0',
  `atra_points_series` tinyint(1) not null default '0',
  `bar_points` int(11) not null,
  `ironman` tinyint(1) not null,
  `auto_combined_results` tinyint(1) not null default '1',
  `promoter_id` int(11) default null,
  primary key (`id`),
  key `idx_disciplined` (`discipline`),
  key `parent_id` (`parent_id`),
  key `idx_type` (`type`),
  key `events_number_issuer_id_index` (`number_issuer_id`),
  key `velodrome_id` (`velodrome_id`),
  key `index_events_on_type` (`type`),
  key `idx_date` (`date`),
  key `index_events_on_sanctioned_by` (`sanctioned_by`),
  key `index_events_on_bar_points` (`bar_points`),
  key `index_events_on_promoter_id` (`promoter_id`),
  constraint `events_events_id_fk` foreign key (`parent_id`) references `events` (`id`) on delete cascade,
  constraint `events_number_issuers_id_fk` foreign key (`number_issuer_id`) references `number_issuers` (`id`),
  constraint `events_promoter_id` foreign key (`promoter_id`) references `people` (`id`) on delete set null,
  constraint `events_velodrome_id_fk` foreign key (`velodrome_id`) references `velodromes` (`id`)
) engine=innodb default charset=utf8;

create table `historical_names` (
  `id` int(11) not null auto_increment,
  `team_id` int(11) not null,
  `name` varchar(255) not null,
  `year` int(11) not null,
  `created_at` datetime default null,
  `updated_at` datetime default null,
  `lock_version` int(11) not null default '0',
  primary key (`id`),
  key `team_id` (`team_id`),
  key `index_names_on_name` (`name`),
  key `index_names_on_year` (`year`),
  constraint `historical_names_team_id_fk` foreign key (`team_id`) references `teams` (`id`)
) engine=innodb default charset=utf8;

create table `import_files` (
  `id` int(11) not null auto_increment,
  `name` varchar(255) not null,
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  primary key (`id`)
) engine=innodb default charset=utf8;

create table `mailing_lists` (
  `id` int(11) not null auto_increment,
  `name` varchar(255) not null default '',
  `friendly_name` varchar(255) not null default '',
  `subject_line_prefix` varchar(255) not null default '',
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  `description` text,
  primary key (`id`),
  key `idx_name` (`name`)
) engine=innodb default charset=utf8;

create table `new_categories` (
  `id` int(11) not null auto_increment,
  `name` varchar(255) default null,
  `type` varchar(255) default null,
  `new_category_id` int(11) default null,
  `position` int(11) not null default '999',
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  primary key (`id`)
) engine=innodb default charset=utf8;

create table `number_issuers` (
  `id` int(11) not null auto_increment,
  `name` varchar(255) not null default '',
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  primary key (`id`),
  unique key `number_issuers_name_index` (`name`)
) engine=innodb default charset=utf8;

create table `page_versions` (
  `id` int(11) not null auto_increment,
  `page_id` int(11) not null,
  `parent_id` int(11) default null,
  `author_id` int(11) default null,
  `body` text,
  `path` varchar(255) default null,
  `slug` varchar(255) default null,
  `title` varchar(255) default null,
  `lock_version` int(11) default null,
  `created_at` datetime default null,
  `updated_at` datetime default null,
  primary key (`id`),
  key `index_page_versions_on_page_id` (`page_id`)
) engine=innodb default charset=utf8;

create table `pages` (
  `id` int(11) not null auto_increment,
  `parent_id` int(11) default null,
  `body` text not null,
  `path` varchar(255) not null default '',
  `slug` varchar(255) not null default '',
  `title` varchar(255) not null default '',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  `author_id` int(11) default null,
  `lock_version` int(11) not null default '0',
  primary key (`id`),
  unique key `index_pages_on_path` (`path`),
  key `parent_id` (`parent_id`),
  key `index_pages_on_slug` (`slug`),
  constraint `pages_parent_id_fk` foreign key (`parent_id`) references `pages` (`id`)
) engine=innodb default charset=utf8;

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
  `created_by_type` varchar(255) default null,
  `member_usac_to` date default null,
  `crypted_password` varchar(255) default null,
  `password_salt` varchar(255) default null,
  `persistence_token` varchar(255) not null,
  `single_access_token` varchar(255) default null,
  `perishable_token` varchar(255) default null,
  `login_count` int(11) not null default '0',
  `failed_login_count` int(11) not null default '0',
  `last_request_at` datetime default null,
  `current_login_at` datetime default null,
  `last_login_at` datetime default null,
  `current_login_ip` varchar(255) default null,
  `last_login_ip` varchar(255) default null,
  `login` varchar(100) default null,
  `string` varchar(100) default null,
  `created_by_id` int(11) default null,
  primary key (`id`),
  unique key `index_people_on_login` (`login`),
  key `idx_last_name` (`last_name`),
  key `idx_first_name` (`first_name`),
  key `idx_team_id` (`team_id`),
  key `index_racers_on_member_to` (`member_to`),
  key `index_racers_on_member_from` (`member_from`),
  key `index_people_on_crypted_password` (`crypted_password`),
  key `index_people_on_persistence_token` (`persistence_token`),
  key `index_people_on_perishable_token` (`perishable_token`),
  key `index_people_on_single_access_token` (`single_access_token`),
  key `index_people_on_created_by_id` (`created_by_id`),
  constraint `racers_team_id_fk` foreign key (`team_id`) references `teams` (`id`)
) engine=innodb default charset=utf8;

create table `people_roles` (
  `role_id` int(11) not null,
  `person_id` int(11) not null,
  key `role_id` (`role_id`),
  key `index_people_roles_on_person_id` (`person_id`),
  constraint `people_roles_person_id` foreign key (`person_id`) references `people` (`id`) on delete cascade,
  constraint `roles_users_role_id_fk` foreign key (`role_id`) references `roles` (`id`) on delete cascade
) engine=innodb default charset=utf8;

create table `posts` (
  `id` int(11) not null auto_increment,
  `body` text not null,
  `date` timestamp not null default '0000-00-00 00:00:00',
  `sender` varchar(255) not null default '',
  `subject` varchar(255) not null default '',
  `topica_message_id` varchar(255) default null,
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  `mailing_list_id` int(11) not null default '0',
  primary key (`id`),
  unique key `idx_topica_message_id` (`topica_message_id`),
  key `idx_date` (`date`),
  key `idx_sender` (`sender`),
  key `idx_subject` (`subject`),
  key `idx_mailing_list_id` (`mailing_list_id`),
  key `idx_date_list` (`date`,`mailing_list_id`),
  constraint `posts_mailing_list_id_fk` foreign key (`mailing_list_id`) references `mailing_lists` (`id`)
) engine=innodb default charset=utf8;

create table `race_numbers` (
  `id` int(11) not null auto_increment,
  `person_id` int(11) not null default '0',
  `discipline_id` int(11) not null default '0',
  `number_issuer_id` int(11) not null default '0',
  `value` varchar(255) not null default '',
  `year` int(11) not null default '0',
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  `updated_by` varchar(255) default null,
  primary key (`id`),
  key `racer_id` (`person_id`),
  key `discipline_id` (`discipline_id`),
  key `number_issuer_id` (`number_issuer_id`),
  key `race_numbers_value_index` (`value`),
  constraint `race_numbers_person_id` foreign key (`person_id`) references `people` (`id`) on delete cascade,
  constraint `race_numbers_discipline_id_fk` foreign key (`discipline_id`) references `disciplines` (`id`),
  constraint `race_numbers_number_issuer_id_fk` foreign key (`number_issuer_id`) references `number_issuers` (`id`)
) engine=innodb default charset=utf8;

create table `races` (
  `id` int(11) not null auto_increment,
  `category_id` int(11) not null,
  `city` varchar(128) default null,
  `distance` int(11) default null,
  `state` varchar(64) default null,
  `field_size` int(11) default null,
  `laps` int(11) default null,
  `time` float default null,
  `finishers` int(11) default null,
  `notes` varchar(255) default '',
  `sanctioned_by` varchar(255) default null,
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  `result_columns` varchar(255) default null,
  `bar_points` int(11) default null,
  `event_id` int(11) not null,
  primary key (`id`),
  key `idx_category_id` (`category_id`),
  key `index_races_on_event_id` (`event_id`),
  key `index_races_on_bar_points` (`bar_points`),
  constraint `races_event_id_fk` foreign key (`event_id`) references `events` (`id`) on delete cascade,
  constraint `races_category_id_fk` foreign key (`category_id`) references `categories` (`id`)
) engine=innodb default charset=utf8;

create table `results` (
  `id` int(11) not null auto_increment,
  `category_id` int(11) default null,
  `person_id` int(11) default null,
  `race_id` int(11) not null,
  `team_id` int(11) default null,
  `age` int(11) default null,
  `city` varchar(128) default null,
  `date_of_birth` datetime default null,
  `is_series` tinyint(1) default null,
  `license` varchar(64) default '',
  `notes` varchar(255) default null,
  `number` varchar(16) default '',
  `place` varchar(8) default '',
  `place_in_category` int(11) default '0',
  `points` float default '0',
  `points_from_place` float default '0',
  `points_bonus_penalty` float default '0',
  `points_total` float default '0',
  `state` varchar(64) default null,
  `status` char(3) default null,
  `time` double default null,
  `time_bonus_penalty` double default null,
  `time_gap_to_leader` double default null,
  `time_gap_to_previous` double default null,
  `time_gap_to_winner` double default null,
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  `time_total` double default null,
  `laps` int(11) default null,
  `members_only_place` varchar(8) default null,
  `points_bonus` int(11) not null default '0',
  `points_penalty` int(11) not null default '0',
  `preliminary` tinyint(1) default null,
  `bar` tinyint(1) default '1',
  primary key (`id`),
  key `idx_category_id` (`category_id`),
  key `idx_race_id` (`race_id`),
  key `idx_racer_id` (`person_id`),
  key `idx_team_id` (`team_id`),
  key `index_results_on_place` (`place`),
  key `index_results_on_members_only_place` (`members_only_place`),
  constraint `results_person_id` foreign key (`person_id`) references `people` (`id`),
  constraint `results_category_id_fk` foreign key (`category_id`) references `categories` (`id`),
  constraint `results_race_id_fk` foreign key (`race_id`) references `races` (`id`) on delete cascade,
  constraint `results_team_id_fk` foreign key (`team_id`) references `teams` (`id`)
) engine=innodb default charset=utf8;

create table `roles` (
  `id` int(11) not null auto_increment,
  `name` varchar(255) default null,
  primary key (`id`)
) engine=innodb default charset=utf8;

create table `schema_migrations` (
  `version` varchar(255) not null,
  unique key `unique_schema_migrations` (`version`)
) engine=innodb default charset=utf8;

create table `scores` (
  `id` int(11) not null auto_increment,
  `competition_result_id` int(11) default null,
  `source_result_id` int(11) default null,
  `points` double default null,
  `created_at` datetime default null,
  `updated_at` datetime default null,
  primary key (`id`),
  key `scores_competition_result_id_index` (`competition_result_id`),
  key `scores_source_result_id_index` (`source_result_id`),
  constraint `scores_source_result_id_fk` foreign key (`source_result_id`) references `results` (`id`) on delete cascade,
  constraint `scores_competition_result_id_fk` foreign key (`competition_result_id`) references `results` (`id`) on delete cascade
) engine=innodb default charset=utf8;

create table `teams` (
  `id` int(11) not null auto_increment,
  `name` varchar(255) not null default '',
  `city` varchar(128) default null,
  `state` varchar(64) default null,
  `notes` varchar(255) default null,
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  `member` tinyint(1) default '0',
  `website` varchar(255) default null,
  `sponsors` varchar(1000) default null,
  `contact_name` varchar(255) default null,
  `contact_email` varchar(255) default null,
  `contact_phone` varchar(255) default null,
  `show_on_public_page` tinyint(1) default '0',
  `created_by_type` varchar(255) default null,
  `created_by_id` int(11) default null,
  primary key (`id`),
  unique key `idx_name` (`name`),
  key `index_teams_on_created_by_id` (`created_by_id`)
) engine=innodb default charset=utf8;

create table `velodromes` (
  `id` int(11) not null auto_increment,
  `name` varchar(255) default null,
  `website` varchar(255) default null,
  `lock_version` int(11) not null default '0',
  `created_at` datetime default null,
  `updated_at` datetime default null,
  primary key (`id`),
  key `index_velodromes_on_name` (`name`)
) engine=innodb default charset=utf8;

insert into schema_migrations (version) values ('1');

insert into schema_migrations (version) values ('10');

insert into schema_migrations (version) values ('11');

insert into schema_migrations (version) values ('12');

insert into schema_migrations (version) values ('13');

insert into schema_migrations (version) values ('14');

insert into schema_migrations (version) values ('15');

insert into schema_migrations (version) values ('16');

insert into schema_migrations (version) values ('17');

insert into schema_migrations (version) values ('18');

insert into schema_migrations (version) values ('19');

insert into schema_migrations (version) values ('2');

insert into schema_migrations (version) values ('20');

insert into schema_migrations (version) values ('20080901043711');

insert into schema_migrations (version) values ('20080923001805');

insert into schema_migrations (version) values ('20080928152814');

insert into schema_migrations (version) values ('20081001234859');

insert into schema_migrations (version) values ('20081101221844');

insert into schema_migrations (version) values ('20081102001855');

insert into schema_migrations (version) values ('20081214033053');

insert into schema_migrations (version) values ('20090116235413');

insert into schema_migrations (version) values ('20090117215129');

insert into schema_migrations (version) values ('20090212200352');

insert into schema_migrations (version) values ('20090217170845');

insert into schema_migrations (version) values ('20090217170956');

insert into schema_migrations (version) values ('20090217212657');

insert into schema_migrations (version) values ('20090217212924');

insert into schema_migrations (version) values ('20090224224826');

insert into schema_migrations (version) values ('20090225004224');

insert into schema_migrations (version) values ('20090305222446');

insert into schema_migrations (version) values ('20090310155105');

insert into schema_migrations (version) values ('20090312003519');

insert into schema_migrations (version) values ('20090313231845');

insert into schema_migrations (version) values ('20090316162742');

insert into schema_migrations (version) values ('20090324032935');

insert into schema_migrations (version) values ('20090326190925');

insert into schema_migrations (version) values ('20090326192755');

insert into schema_migrations (version) values ('20090328185643');

insert into schema_migrations (version) values ('20090409205042');

insert into schema_migrations (version) values ('20090422162313');

insert into schema_migrations (version) values ('20090422173446');

insert into schema_migrations (version) values ('20090423002956');

insert into schema_migrations (version) values ('20090504040327');

insert into schema_migrations (version) values ('20090504040328');

insert into schema_migrations (version) values ('20090505151122');

insert into schema_migrations (version) values ('20090514202305');

insert into schema_migrations (version) values ('20090519034739');

insert into schema_migrations (version) values ('20090620000926');

insert into schema_migrations (version) values ('21');

insert into schema_migrations (version) values ('22');

insert into schema_migrations (version) values ('23');

insert into schema_migrations (version) values ('24');

insert into schema_migrations (version) values ('25');

insert into schema_migrations (version) values ('26');

insert into schema_migrations (version) values ('27');

insert into schema_migrations (version) values ('28');

insert into schema_migrations (version) values ('29');

insert into schema_migrations (version) values ('3');

insert into schema_migrations (version) values ('30');

insert into schema_migrations (version) values ('31');

insert into schema_migrations (version) values ('32');

insert into schema_migrations (version) values ('33');

insert into schema_migrations (version) values ('34');

insert into schema_migrations (version) values ('35');

insert into schema_migrations (version) values ('36');

insert into schema_migrations (version) values ('37');

insert into schema_migrations (version) values ('38');

insert into schema_migrations (version) values ('39');

insert into schema_migrations (version) values ('4');

insert into schema_migrations (version) values ('40');

insert into schema_migrations (version) values ('41');

insert into schema_migrations (version) values ('42');

insert into schema_migrations (version) values ('43');

insert into schema_migrations (version) values ('44');

insert into schema_migrations (version) values ('45');

insert into schema_migrations (version) values ('46');

insert into schema_migrations (version) values ('47');

insert into schema_migrations (version) values ('48');

insert into schema_migrations (version) values ('49');

insert into schema_migrations (version) values ('5');

insert into schema_migrations (version) values ('50');

insert into schema_migrations (version) values ('51');

insert into schema_migrations (version) values ('52');

insert into schema_migrations (version) values ('53');

insert into schema_migrations (version) values ('54');

insert into schema_migrations (version) values ('55');

insert into schema_migrations (version) values ('56');

insert into schema_migrations (version) values ('57');

insert into schema_migrations (version) values ('6');

insert into schema_migrations (version) values ('7');

insert into schema_migrations (version) values ('8');

insert into schema_migrations (version) values ('9');