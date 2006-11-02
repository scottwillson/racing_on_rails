-- MySQL dump 10.10
--
-- Host: localhost    Database: racing_on_rails_development
-- ------------------------------------------------------
-- Server version	5.0.24-standard

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `aliases`
--

DROP TABLE IF EXISTS `aliases`;
CREATE TABLE `aliases` (
  `id` int(11) NOT NULL auto_increment,
  `alias` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  `racer_id` int(11) default NULL,
  `team_id` int(11) default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_name` (`name`),
  KEY `idx_id` (`alias`),
  KEY `idx_racer_id` (`racer_id`),
  KEY `idx_team_id` (`team_id`),
  CONSTRAINT `aliases_ibfk_1` FOREIGN KEY (`racer_id`) REFERENCES `racers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `aliases_ibfk_2` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `aliases_disciplines`
--

DROP TABLE IF EXISTS `aliases_disciplines`;
CREATE TABLE `aliases_disciplines` (
  `discipline_id` int(11) NOT NULL default '0',
  `alias` varchar(64) NOT NULL default '',
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  KEY `idx_alias` (`alias`),
  KEY `idx_discipline_id` (`discipline_id`),
  CONSTRAINT `aliases_disciplines_ibfk_1` FOREIGN KEY (`discipline_id`) REFERENCES `disciplines` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `bike_shops`
--

DROP TABLE IF EXISTS `bike_shops`;
CREATE TABLE `bike_shops` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `phone` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `id` int(11) NOT NULL auto_increment,
  `bar_category_id` int(11) default NULL,
  `position` int(11) NOT NULL default '0',
  `is_overall` int(11) NOT NULL default '0',
  `name` varchar(64) NOT NULL default '',
  `overall_id` int(11) default NULL,
  `scheme` varchar(255) default '',
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_category_name_scheme` (`name`,`scheme`),
  KEY `idx_bar_category_id` (`bar_category_id`),
  KEY `idx_overall_id` (`overall_id`),
  CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`bar_category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `categories_ibfk_2` FOREIGN KEY (`overall_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `discipline_bar_categories`
--

DROP TABLE IF EXISTS `discipline_bar_categories`;
CREATE TABLE `discipline_bar_categories` (
  `category_id` int(11) NOT NULL default '0',
  `discipline_id` int(11) NOT NULL default '0',
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  KEY `idx_category_id` (`category_id`),
  KEY `idx_discipline_id` (`discipline_id`),
  CONSTRAINT `discipline_bar_categories_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `discipline_bar_categories_ibfk_2` FOREIGN KEY (`discipline_id`) REFERENCES `disciplines` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `disciplines`
--

DROP TABLE IF EXISTS `disciplines`;
CREATE TABLE `disciplines` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(64) NOT NULL default '',
  `bar` tinyint(1) default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `engine_schema_info`
--

DROP TABLE IF EXISTS `engine_schema_info`;
CREATE TABLE `engine_schema_info` (
  `engine_name` varchar(255) default NULL,
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
CREATE TABLE `events` (
  `id` int(11) NOT NULL auto_increment,
  `promoter_id` int(11) default NULL,
  `parent_id` int(11) default NULL,
  `city` varchar(128) default NULL,
  `date` date default NULL,
  `discipline` varchar(32) default NULL,
  `flyer` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  `notes` varchar(255) default '',
  `sanctioned_by` varchar(255) default NULL,
  `state` varchar(64) default NULL,
  `type` varchar(32) NOT NULL default '',
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `flyer_approved` tinyint(1) NOT NULL default '0',
  `cancelled` tinyint(1) default '0',
  `oregon_cup_id` int(11) default NULL,
  `notification` tinyint(1) default '1',
  `number_issuer_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `idx_date` (`date`),
  KEY `idx_disciplined` (`discipline`),
  KEY `parent_id` (`parent_id`),
  KEY `idx_promoter_id` (`promoter_id`),
  KEY `idx_type` (`type`),
  KEY `oregon_cup_id` (`oregon_cup_id`),
  KEY `events_number_issuer_id_index` (`number_issuer_id`),
  CONSTRAINT `events_ibfk_5` FOREIGN KEY (`number_issuer_id`) REFERENCES `number_issuers` (`id`),
  CONSTRAINT `events_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `events` (`id`) ON DELETE CASCADE,
  CONSTRAINT `events_ibfk_2` FOREIGN KEY (`promoter_id`) REFERENCES `promoters` (`id`) ON DELETE SET NULL,
  CONSTRAINT `events_ibfk_3` FOREIGN KEY (`oregon_cup_id`) REFERENCES `events` (`id`) ON DELETE SET NULL,
  CONSTRAINT `events_ibfk_4` FOREIGN KEY (`number_issuer_id`) REFERENCES `number_issuers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `number_issuers`
--

DROP TABLE IF EXISTS `number_issuers`;
CREATE TABLE `number_issuers` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `promoters`
--

DROP TABLE IF EXISTS `promoters`;
CREATE TABLE `promoters` (
  `id` int(11) NOT NULL auto_increment,
  `email` varchar(255) default NULL,
  `name` varchar(255) default '',
  `phone` varchar(255) default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `promoter_info` (`name`,`email`,`phone`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `race_numbers`
--

DROP TABLE IF EXISTS `race_numbers`;
CREATE TABLE `race_numbers` (
  `id` int(11) NOT NULL auto_increment,
  `racer_id` int(11) NOT NULL,
  `discipline_id` int(11) NOT NULL,
  `number_issuer_id` int(11) NOT NULL,
  `value` varchar(255) NOT NULL,
  `year` int(11) NOT NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `racer_id` (`racer_id`),
  KEY `number_issuer_id` (`number_issuer_id`),
  KEY `discipline_id` (`discipline_id`),
  KEY `race_numbers_value_index` (`value`),
  CONSTRAINT `race_numbers_ibfk_1` FOREIGN KEY (`racer_id`) REFERENCES `racers` (`id`),
  CONSTRAINT `race_numbers_ibfk_2` FOREIGN KEY (`discipline_id`) REFERENCES `disciplines` (`id`),
  CONSTRAINT `race_numbers_ibfk_3` FOREIGN KEY (`number_issuer_id`) REFERENCES `number_issuers` (`id`),
  CONSTRAINT `race_numbers_ibfk_4` FOREIGN KEY (`racer_id`) REFERENCES `racers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `race_numbers_ibfk_5` FOREIGN KEY (`number_issuer_id`) REFERENCES `number_issuers` (`id`),
  CONSTRAINT `race_numbers_ibfk_6` FOREIGN KEY (`discipline_id`) REFERENCES `disciplines` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `racers`
--

DROP TABLE IF EXISTS `racers`;
CREATE TABLE `racers` (
  `id` int(11) NOT NULL auto_increment,
  `first_name` varchar(64) default NULL,
  `last_name` varchar(255) default NULL,
  `member` tinyint(1) default '1',
  `age` int(11) default NULL,
  `city` varchar(128) default NULL,
  `date_of_birth` date default NULL,
  `license` varchar(64) default NULL,
  `notes` varchar(255) default NULL,
  `state` varchar(64) default NULL,
  `team_id` int(11) default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `cell_fax` varchar(255) default NULL,
  `ccx_category` varchar(255) default NULL,
  `dh_category` varchar(255) default NULL,
  `dh_number` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `gender` char(2) default NULL,
  `home_phone` varchar(255) default NULL,
  `mtb_category` varchar(255) default NULL,
  `member_on` date default NULL,
  `occupation` varchar(255) default NULL,
  `road_category` varchar(255) default NULL,
  `street` varchar(255) default NULL,
  `track_category` varchar(255) default NULL,
  `work_phone` varchar(255) default NULL,
  `xc_number` varchar(255) default NULL,
  `zip` varchar(255) default NULL,
  `road_number` varchar(255) default NULL,
  `ccx_number` varchar(255) default NULL,
  `track_number` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_road_number` (`road_number`),
  UNIQUE KEY `idx_ccx_number` (`ccx_number`),
  UNIQUE KEY `idx_dh_number` (`dh_number`),
  UNIQUE KEY `idx_track_number` (`track_number`),
  KEY `idx_last_name` (`last_name`),
  KEY `idx_first_name` (`first_name`),
  KEY `idx_team_id` (`team_id`),
  CONSTRAINT `racers_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `races`
--

DROP TABLE IF EXISTS `races`;
CREATE TABLE `races` (
  `id` int(11) NOT NULL auto_increment,
  `standings_id` int(11) NOT NULL default '0',
  `category_id` int(11) NOT NULL default '0',
  `city` varchar(128) default NULL,
  `distance` int(11) default NULL,
  `state` varchar(64) default NULL,
  `field_size` int(11) default NULL,
  `laps` int(11) default NULL,
  `time` float default NULL,
  `finishers` int(11) default NULL,
  `notes` varchar(255) default '',
  `sanctioned_by` varchar(255) default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `result_columns` varchar(255) default NULL,
  `bar_points` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_standings_id` (`standings_id`),
  CONSTRAINT `races_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `races_ibfk_2` FOREIGN KEY (`standings_id`) REFERENCES `standings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `results`
--

DROP TABLE IF EXISTS `results`;
CREATE TABLE `results` (
  `id` int(11) NOT NULL auto_increment,
  `category_id` int(11) default NULL,
  `racer_id` int(11) default NULL,
  `race_id` int(11) NOT NULL default '0',
  `team_id` int(11) default NULL,
  `age` int(11) default NULL,
  `city` varchar(128) default NULL,
  `date` datetime default NULL,
  `date_of_birth` datetime default NULL,
  `is_series` tinyint(1) default NULL,
  `license` varchar(64) default '',
  `notes` varchar(255) default NULL,
  `number` varchar(16) default '',
  `place` varchar(8) default '',
  `place_in_category` int(11) default '0',
  `points` float default '0',
  `points_from_place` float default '0',
  `points_bonus_penalty` float default '0',
  `points_total` float default '0',
  `state` varchar(64) default NULL,
  `status` char(3) default NULL,
  `time` double default NULL,
  `time_bonus_penalty` double default NULL,
  `time_gap_to_leader` double default NULL,
  `time_gap_to_previous` double default NULL,
  `time_gap_to_winner` double default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `time_total` double default NULL,
  `laps` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_race_id` (`race_id`),
  KEY `idx_racer_id` (`racer_id`),
  KEY `idx_team_id` (`team_id`),
  CONSTRAINT `results_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `results_ibfk_3` FOREIGN KEY (`race_id`) REFERENCES `races` (`id`) ON DELETE CASCADE,
  CONSTRAINT `results_ibfk_4` FOREIGN KEY (`racer_id`) REFERENCES `racers` (`id`),
  CONSTRAINT `results_ibfk_5` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `schema_info`
--

DROP TABLE IF EXISTS `schema_info`;
CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `scores`
--

DROP TABLE IF EXISTS `scores`;
CREATE TABLE `scores` (
  `id` int(11) NOT NULL auto_increment,
  `competition_result_id` int(11) default NULL,
  `source_result_id` int(11) default NULL,
  `points` double default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `scores_competition_result_id_index` (`competition_result_id`),
  KEY `scores_source_result_id_index` (`source_result_id`),
  CONSTRAINT `scores_ibfk_1` FOREIGN KEY (`competition_result_id`) REFERENCES `results` (`id`) ON DELETE CASCADE,
  CONSTRAINT `scores_ibfk_2` FOREIGN KEY (`source_result_id`) REFERENCES `results` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `standings`
--

DROP TABLE IF EXISTS `standings`;
CREATE TABLE `standings` (
  `id` int(11) NOT NULL auto_increment,
  `event_id` int(11) NOT NULL default '0',
  `bar_points` int(11) default '1',
  `date` datetime default NULL,
  `name` varchar(255) default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `ironman` tinyint(1) default '1',
  `position` int(11) default '0',
  `discipline` varchar(32) default NULL,
  `notes` varchar(255) default '',
  `source_id` int(11) default NULL,
  `type` varchar(32) default NULL,
  PRIMARY KEY  (`id`),
  KEY `idx_date` (`date`),
  KEY `event_id` (`event_id`),
  KEY `source_id` (`source_id`),
  CONSTRAINT `standings_ibfk_1` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE,
  CONSTRAINT `standings_ibfk_2` FOREIGN KEY (`source_id`) REFERENCES `standings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `standings_ibfk_3` FOREIGN KEY (`source_id`) REFERENCES `standings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `teams`
--

DROP TABLE IF EXISTS `teams`;
CREATE TABLE `teams` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `city` varchar(128) default NULL,
  `state` varchar(64) default NULL,
  `notes` varchar(255) default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `member` tinyint(1) default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `username` varchar(255) NOT NULL default '',
  `password` varchar(255) NOT NULL default '',
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_alias` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

