CREATE TABLE `aliases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `alias` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `racer_id` int(11) DEFAULT NULL,
  `team_id` int(11) DEFAULT NULL,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_name` (`name`),
  KEY `idx_id` (`alias`),
  KEY `idx_racer_id` (`racer_id`),
  KEY `idx_team_id` (`team_id`),
  CONSTRAINT `aliases_ibfk_1` FOREIGN KEY (`racer_id`) REFERENCES `racers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `aliases_ibfk_2` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7923 DEFAULT CHARSET=latin1;

CREATE TABLE `bids` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `email` varchar(255) NOT NULL DEFAULT '',
  `phone` varchar(255) NOT NULL DEFAULT '',
  `amount` int(11) NOT NULL DEFAULT '0',
  `approved` tinyint(1) DEFAULT NULL,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `position` int(11) NOT NULL DEFAULT '0',
  `name` varchar(64) NOT NULL DEFAULT '',
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `ages_begin` int(11) DEFAULT '0',
  `ages_end` int(11) DEFAULT '999',
  `friendly_param` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_name_index` (`name`),
  KEY `parent_id` (`parent_id`),
  KEY `index_categories_on_friendly_param` (`friendly_param`),
  CONSTRAINT `categories_ibfk_3` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=1953 DEFAULT CHARSET=latin1;

CREATE TABLE `discipline_aliases` (
  `discipline_id` int(11) NOT NULL DEFAULT '0',
  `alias` varchar(64) NOT NULL DEFAULT '',
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  KEY `idx_alias` (`alias`),
  KEY `idx_discipline_id` (`discipline_id`),
  CONSTRAINT `discipline_aliases_ibfk_1` FOREIGN KEY (`discipline_id`) REFERENCES `disciplines` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `discipline_bar_categories` (
  `category_id` int(11) NOT NULL DEFAULT '0',
  `discipline_id` int(11) NOT NULL DEFAULT '0',
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  UNIQUE KEY `discipline_bar_categories_category_id_index` (`category_id`,`discipline_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_discipline_id` (`discipline_id`),
  CONSTRAINT `discipline_bar_categories_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `discipline_bar_categories_ibfk_2` FOREIGN KEY (`discipline_id`) REFERENCES `disciplines` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `disciplines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL DEFAULT '',
  `bar` tinyint(1) DEFAULT NULL,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `numbers` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;

CREATE TABLE `duplicates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `new_attributes` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `duplicates_racers` (
  `racer_id` int(11) DEFAULT NULL,
  `duplicate_id` int(11) DEFAULT NULL,
  UNIQUE KEY `index_duplicates_racers_on_racer_id_and_duplicate_id` (`racer_id`,`duplicate_id`),
  KEY `index_duplicates_racers_on_racer_id` (`racer_id`),
  KEY `index_duplicates_racers_on_duplicate_id` (`duplicate_id`),
  CONSTRAINT `duplicates_racers_ibfk_1` FOREIGN KEY (`racer_id`) REFERENCES `racers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `duplicates_racers_ibfk_2` FOREIGN KEY (`duplicate_id`) REFERENCES `duplicates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `promoter_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `city` varchar(128) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `discipline` varchar(32) DEFAULT NULL,
  `flyer` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `notes` varchar(255) DEFAULT '',
  `sanctioned_by` varchar(255) DEFAULT NULL,
  `state` varchar(64) DEFAULT NULL,
  `type` varchar(32) NOT NULL DEFAULT '',
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `flyer_approved` tinyint(1) NOT NULL DEFAULT '0',
  `cancelled` tinyint(1) DEFAULT '0',
  `oregon_cup_id` int(11) DEFAULT NULL,
  `notification` tinyint(1) DEFAULT '1',
  `number_issuer_id` int(11) DEFAULT NULL,
  `first_aid_provider` varchar(255) DEFAULT '-------------',
  `pre_event_fees` float DEFAULT NULL,
  `post_event_fees` float DEFAULT NULL,
  `flyer_ad_fee` float DEFAULT NULL,
  `cat4_womens_race_series_id` int(11) DEFAULT NULL,
  `prize_list` varchar(255) DEFAULT NULL,
  `velodrome_id` int(11) DEFAULT NULL,
  `time` varchar(255) DEFAULT NULL,
  `instructional` tinyint(1) DEFAULT '0',
  `practice` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_date` (`date`),
  KEY `idx_disciplined` (`discipline`),
  KEY `parent_id` (`parent_id`),
  KEY `idx_promoter_id` (`promoter_id`),
  KEY `idx_type` (`type`),
  KEY `oregon_cup_id` (`oregon_cup_id`),
  KEY `events_number_issuer_id_index` (`number_issuer_id`),
  KEY `velodrome_id` (`velodrome_id`),
  CONSTRAINT `events_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `events` (`id`) ON DELETE CASCADE,
  CONSTRAINT `events_ibfk_2` FOREIGN KEY (`promoter_id`) REFERENCES `promoters` (`id`) ON DELETE SET NULL,
  CONSTRAINT `events_ibfk_3` FOREIGN KEY (`oregon_cup_id`) REFERENCES `events` (`id`) ON DELETE SET NULL,
  CONSTRAINT `events_ibfk_4` FOREIGN KEY (`number_issuer_id`) REFERENCES `number_issuers` (`id`),
  CONSTRAINT `events_ibfk_5` FOREIGN KEY (`number_issuer_id`) REFERENCES `number_issuers` (`id`),
  CONSTRAINT `events_ibfk_6` FOREIGN KEY (`velodrome_id`) REFERENCES `velodromes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13904 DEFAULT CHARSET=latin1;

CREATE TABLE `historical_names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `team_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `year` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `team_id` (`team_id`),
  KEY `index_names_on_name` (`name`),
  KEY `index_names_on_year` (`year`),
  CONSTRAINT `historical_names_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=latin1;

CREATE TABLE `images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `caption` varchar(255) DEFAULT NULL,
  `html_options` varchar(255) DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `source` varchar(255) NOT NULL DEFAULT '',
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `images_name_index` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

CREATE TABLE `mailing_lists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `friendly_name` varchar(255) NOT NULL DEFAULT '',
  `subject_line_prefix` varchar(255) NOT NULL DEFAULT '',
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`id`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

CREATE TABLE `new_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `new_category_id` int(11) DEFAULT NULL,
  `position` int(11) NOT NULL DEFAULT '999',
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `news_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `text` varchar(255) NOT NULL DEFAULT '',
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `news_items_date_index` (`date`),
  KEY `news_items_text_index` (`text`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

CREATE TABLE `number_issuers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `number_issuers_name_index` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

CREATE TABLE `posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `body` text NOT NULL,
  `date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `sender` varchar(255) NOT NULL DEFAULT '',
  `subject` varchar(255) NOT NULL DEFAULT '',
  `topica_message_id` varchar(255) DEFAULT NULL,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `mailing_list_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_topica_message_id` (`topica_message_id`),
  KEY `idx_date` (`date`),
  KEY `idx_sender` (`sender`),
  KEY `idx_subject` (`subject`),
  KEY `idx_mailing_list_id` (`mailing_list_id`),
  KEY `idx_date_list` (`date`,`mailing_list_id`),
  CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`mailing_list_id`) REFERENCES `mailing_lists` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `promoters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT '',
  `phone` varchar(255) DEFAULT NULL,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `promoter_info` (`name`,`email`,`phone`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=154 DEFAULT CHARSET=latin1;

CREATE TABLE `race_numbers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `racer_id` int(11) NOT NULL DEFAULT '0',
  `discipline_id` int(11) NOT NULL DEFAULT '0',
  `number_issuer_id` int(11) NOT NULL DEFAULT '0',
  `value` varchar(255) NOT NULL DEFAULT '',
  `year` int(11) NOT NULL DEFAULT '0',
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `racer_id` (`racer_id`),
  KEY `discipline_id` (`discipline_id`),
  KEY `number_issuer_id` (`number_issuer_id`),
  KEY `race_numbers_value_index` (`value`),
  CONSTRAINT `race_numbers_ibfk_1` FOREIGN KEY (`racer_id`) REFERENCES `racers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `race_numbers_ibfk_2` FOREIGN KEY (`discipline_id`) REFERENCES `disciplines` (`id`),
  CONSTRAINT `race_numbers_ibfk_3` FOREIGN KEY (`number_issuer_id`) REFERENCES `number_issuers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=50085 DEFAULT CHARSET=latin1;

CREATE TABLE `racers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(64) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `city` varchar(128) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `license` varchar(64) DEFAULT NULL,
  `notes` text,
  `state` varchar(64) DEFAULT NULL,
  `team_id` int(11) DEFAULT NULL,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `cell_fax` varchar(255) DEFAULT NULL,
  `ccx_category` varchar(255) DEFAULT NULL,
  `dh_category` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `gender` char(2) DEFAULT NULL,
  `home_phone` varchar(255) DEFAULT NULL,
  `mtb_category` varchar(255) DEFAULT NULL,
  `member_from` date DEFAULT NULL,
  `occupation` varchar(255) DEFAULT NULL,
  `road_category` varchar(255) DEFAULT NULL,
  `street` varchar(255) DEFAULT NULL,
  `track_category` varchar(255) DEFAULT NULL,
  `work_phone` varchar(255) DEFAULT NULL,
  `zip` varchar(255) DEFAULT NULL,
  `member_to` date DEFAULT NULL,
  `print_card` tinyint(1) DEFAULT '0',
  `print_mailing_label` tinyint(1) DEFAULT '0',
  `ccx_only` tinyint(1) NOT NULL DEFAULT '0',
  `updated_by` varchar(255) DEFAULT NULL,
  `bmx_category` varchar(255) DEFAULT NULL,
  `wants_email` tinyint(1) NOT NULL DEFAULT '1',
  `wants_mail` tinyint(1) NOT NULL DEFAULT '1',
  `volunteer_interest` tinyint(1) NOT NULL DEFAULT '0',
  `official_interest` tinyint(1) NOT NULL DEFAULT '0',
  `race_promotion_interest` tinyint(1) NOT NULL DEFAULT '0',
  `team_interest` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_last_name` (`last_name`),
  KEY `idx_first_name` (`first_name`),
  KEY `idx_team_id` (`team_id`),
  CONSTRAINT `racers_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26771 DEFAULT CHARSET=latin1;

CREATE TABLE `races` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `standings_id` int(11) NOT NULL DEFAULT '0',
  `category_id` int(11) NOT NULL DEFAULT '0',
  `city` varchar(128) DEFAULT NULL,
  `distance` int(11) DEFAULT NULL,
  `state` varchar(64) DEFAULT NULL,
  `field_size` int(11) DEFAULT NULL,
  `laps` int(11) DEFAULT NULL,
  `time` float DEFAULT NULL,
  `finishers` int(11) DEFAULT NULL,
  `notes` varchar(255) DEFAULT '',
  `sanctioned_by` varchar(255) DEFAULT 'OBRA',
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `result_columns` varchar(255) DEFAULT NULL,
  `bar_points` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_standings_id` (`standings_id`),
  CONSTRAINT `races_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `races_ibfk_2` FOREIGN KEY (`standings_id`) REFERENCES `standings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=154462 DEFAULT CHARSET=latin1;

CREATE TABLE `results` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) DEFAULT NULL,
  `racer_id` int(11) DEFAULT NULL,
  `race_id` int(11) NOT NULL DEFAULT '0',
  `team_id` int(11) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `city` varchar(128) DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `date_of_birth` datetime DEFAULT NULL,
  `is_series` tinyint(1) DEFAULT NULL,
  `license` varchar(64) DEFAULT '',
  `notes` varchar(255) DEFAULT NULL,
  `number` varchar(16) DEFAULT '',
  `place` varchar(8) DEFAULT '',
  `place_in_category` int(11) DEFAULT '0',
  `points` float DEFAULT '0',
  `points_from_place` float DEFAULT '0',
  `points_bonus_penalty` float DEFAULT '0',
  `points_total` float DEFAULT '0',
  `state` varchar(64) DEFAULT NULL,
  `status` char(3) DEFAULT NULL,
  `time` double DEFAULT NULL,
  `time_bonus_penalty` double DEFAULT NULL,
  `time_gap_to_leader` double DEFAULT NULL,
  `time_gap_to_previous` double DEFAULT NULL,
  `time_gap_to_winner` double DEFAULT NULL,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `time_total` double DEFAULT NULL,
  `laps` int(11) DEFAULT NULL,
  `members_only_place` varchar(8) DEFAULT NULL,
  `points_bonus` int(11) NOT NULL DEFAULT '0',
  `points_penalty` int(11) NOT NULL DEFAULT '0',
  `preliminary` tinyint(1) DEFAULT NULL,
  `bar` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_race_id` (`race_id`),
  KEY `idx_racer_id` (`racer_id`),
  KEY `idx_team_id` (`team_id`),
  CONSTRAINT `results_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `results_ibfk_3` FOREIGN KEY (`race_id`) REFERENCES `races` (`id`) ON DELETE CASCADE,
  CONSTRAINT `results_ibfk_4` FOREIGN KEY (`racer_id`) REFERENCES `racers` (`id`),
  CONSTRAINT `results_ibfk_5` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9589732 DEFAULT CHARSET=latin1;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `scores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `competition_result_id` int(11) DEFAULT NULL,
  `source_result_id` int(11) DEFAULT NULL,
  `points` double DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `scores_competition_result_id_index` (`competition_result_id`),
  KEY `scores_source_result_id_index` (`source_result_id`),
  CONSTRAINT `scores_ibfk_1` FOREIGN KEY (`competition_result_id`) REFERENCES `results` (`id`) ON DELETE CASCADE,
  CONSTRAINT `scores_ibfk_2` FOREIGN KEY (`source_result_id`) REFERENCES `results` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=31069686 DEFAULT CHARSET=latin1;

CREATE TABLE `standings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event_id` int(11) NOT NULL DEFAULT '0',
  `bar_points` int(11) DEFAULT '1',
  `name` varchar(255) DEFAULT NULL,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `ironman` tinyint(1) DEFAULT '1',
  `position` int(11) DEFAULT '0',
  `discipline` varchar(32) DEFAULT NULL,
  `notes` varchar(255) DEFAULT '',
  `source_id` int(11) DEFAULT NULL,
  `type` varchar(32) DEFAULT NULL,
  `auto_combined_standings` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `event_id` (`event_id`),
  KEY `source_id` (`source_id`),
  CONSTRAINT `standings_ibfk_1` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE,
  CONSTRAINT `standings_ibfk_2` FOREIGN KEY (`source_id`) REFERENCES `standings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `standings_ibfk_3` FOREIGN KEY (`source_id`) REFERENCES `standings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16122 DEFAULT CHARSET=latin1;

CREATE TABLE `teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `city` varchar(128) DEFAULT NULL,
  `state` varchar(64) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `member` tinyint(1) DEFAULT '0',
  `website` varchar(255) DEFAULT NULL,
  `sponsors` varchar(1000) DEFAULT NULL,
  `contact_name` varchar(255) DEFAULT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  `contact_phone` varchar(255) DEFAULT NULL,
  `show_on_public_page` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7873 DEFAULT CHARSET=latin1;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `username` varchar(255) NOT NULL DEFAULT '',
  `password` varchar(255) NOT NULL DEFAULT '',
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_alias` (`username`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

CREATE TABLE `velodromes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('20080901043711');

INSERT INTO schema_migrations (version) VALUES ('20080923001805');

INSERT INTO schema_migrations (version) VALUES ('20080928152814');

INSERT INTO schema_migrations (version) VALUES ('20081001234859');

INSERT INTO schema_migrations (version) VALUES ('20081101221844');

INSERT INTO schema_migrations (version) VALUES ('20081102001855');

INSERT INTO schema_migrations (version) VALUES ('20081214033053');

INSERT INTO schema_migrations (version) VALUES ('20090116235413');

INSERT INTO schema_migrations (version) VALUES ('20090117215129');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('28');

INSERT INTO schema_migrations (version) VALUES ('29');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('30');

INSERT INTO schema_migrations (version) VALUES ('31');

INSERT INTO schema_migrations (version) VALUES ('32');

INSERT INTO schema_migrations (version) VALUES ('33');

INSERT INTO schema_migrations (version) VALUES ('34');

INSERT INTO schema_migrations (version) VALUES ('35');

INSERT INTO schema_migrations (version) VALUES ('36');

INSERT INTO schema_migrations (version) VALUES ('37');

INSERT INTO schema_migrations (version) VALUES ('38');

INSERT INTO schema_migrations (version) VALUES ('39');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('40');

INSERT INTO schema_migrations (version) VALUES ('41');

INSERT INTO schema_migrations (version) VALUES ('42');

INSERT INTO schema_migrations (version) VALUES ('43');

INSERT INTO schema_migrations (version) VALUES ('44');

INSERT INTO schema_migrations (version) VALUES ('45');

INSERT INTO schema_migrations (version) VALUES ('46');

INSERT INTO schema_migrations (version) VALUES ('47');

INSERT INTO schema_migrations (version) VALUES ('48');

INSERT INTO schema_migrations (version) VALUES ('49');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('50');

INSERT INTO schema_migrations (version) VALUES ('51');

INSERT INTO schema_migrations (version) VALUES ('52');

INSERT INTO schema_migrations (version) VALUES ('53');

INSERT INTO schema_migrations (version) VALUES ('54');

INSERT INTO schema_migrations (version) VALUES ('55');

INSERT INTO schema_migrations (version) VALUES ('56');

INSERT INTO schema_migrations (version) VALUES ('57');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');