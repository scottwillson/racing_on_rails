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

DROP DATABASE IF EXISTS racing_on_rails_test;
create database racing_on_rails_test;
	
DROP DATABASE IF EXISTS racing_on_rails_development;
create database racing_on_rails_development;
use racing_on_rails_development;

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
  KEY `idx_discipline_id` (`discipline_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `disciplines`
--

DROP TABLE IF EXISTS `disciplines`;
CREATE TABLE `disciplines` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(64) NOT NULL default '',
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  `notification` tinyint(1) default '1',
  PRIMARY KEY  (`id`),
  KEY `idx_date` (`date`),
  KEY `idx_disciplined` (`discipline`),
  KEY `parent_id` (`parent_id`),
  KEY `idx_promoter_id` (`promoter_id`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `promoters`
--

DROP TABLE IF EXISTS `promoters`;
CREATE TABLE `promoters` (
  `id` int(11) NOT NULL auto_increment,
  `email` varchar(255) default NULL,
  `name` varchar(255) NOT NULL default '',
  `phone` varchar(255) default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `promoter_info` (`name`,`email`,`phone`),
  KEY `idx_name` (`name`)
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

--
-- Table structure for table `teams`
--

DROP TABLE IF EXISTS `teams`;
CREATE TABLE `teams` (
  `id` int(11) NOT NULL auto_increment,
  `city` varchar(128) default NULL,
  `created_at` datetime default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `name` varchar(255) NOT NULL default '',
  `notes` varchar(255) default NULL,
  `obra_member` tinyint(1) default '0',
  `state` varchar(64) default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `racers`
--

DROP TABLE IF EXISTS `racers`;
CREATE TABLE `racers` (
  `id` int(11) NOT NULL auto_increment,
  `age` int(11) default NULL,
  `ccx_category` varchar(255) default NULL,
  `ccx_number` varchar(255) default NULL,
  `cell_fax` varchar(255) default NULL,
  `city` varchar(128) default NULL,
  `created_at` datetime default NULL,
  `date_of_birth` date default NULL,
  `dh_category` varchar(255) default NULL,
  `dh_number` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `first_name` varchar(64) default NULL,
  `gender` char(2) default NULL,
  `home_phone` varchar(255) default NULL,
  `last_name` varchar(255) default NULL,
  `license` varchar(64) default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `mtb_category` varchar(255) default NULL,
  `notes` varchar(255) default NULL,
  `obra_member_on` date default NULL,
  `obra_member` tinyint(1) NOT NULL default '1',
  `occupation` varchar(255) default NULL,
  `road_category` varchar(255) default NULL,
  `road_number` varchar(255) default NULL,
  `state` varchar(64) default NULL,
  `street` varchar(255) default NULL,
  `team_id` int(11) default NULL,
  `track_category` varchar(255) default NULL,
  `track_number` varchar(255) default NULL,
  `updated_at` datetime default NULL,
  `work_phone` varchar(255) default NULL,
  `xc_number` varchar(255) default NULL,
  `zip` varchar(255) default NULL,
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

DROP TABLE IF EXISTS `aliases`;
CREATE TABLE `aliases` (
  `id` int(11) NOT NULL auto_increment,
  `alias` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `name` varchar(255) default NULL,
  `racer_id` int(11) default NULL,
  `team_id` int(11) default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_name` (`name`),
  KEY `idx_id` (`alias`),
  KEY `idx_racer_id` (`racer_id`),
  KEY `idx_team_id` (`team_id`),
  CONSTRAINT `aliases_ibfk_1` FOREIGN KEY (`racer_id`) REFERENCES `racers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `aliases_ibfk_2` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

