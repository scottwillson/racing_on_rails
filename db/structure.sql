-- MySQL dump 10.13  Distrib 5.5.30, for osx10.9 (i386)
--
-- Host: localhost    Database: racing_on_rails_development
-- ------------------------------------------------------
-- Server version	5.5.30

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aliases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `aliasable_type` varchar(255) NOT NULL,
  `aliasable_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_aliases_on_name_and_aliasable_type` (`name`,`aliasable_type`),
  KEY `index_aliases_on_name` (`name`),
  KEY `index_aliases_on_aliasable_type` (`aliasable_type`),
  KEY `index_aliases_on_aliasable_id` (`aliasable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `article_categories`
--

DROP TABLE IF EXISTS `article_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `article_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_id` int(11) DEFAULT '0',
  `position` int(11) DEFAULT '0',
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `articles`
--

DROP TABLE IF EXISTS `articles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `articles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `heading` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `display` tinyint(1) DEFAULT NULL,
  `body` text COLLATE utf8_unicode_ci,
  `position` int(11) DEFAULT '0',
  `article_category_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bids`
--

DROP TABLE IF EXISTS `bids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bids` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(255) NOT NULL,
  `amount` int(11) NOT NULL,
  `approved` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `position` int(11) NOT NULL DEFAULT '0',
  `name` varchar(64) NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `ages_begin` int(11) DEFAULT '0',
  `ages_end` int(11) DEFAULT '999',
  `friendly_param` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_name_index` (`name`),
  KEY `parent_id` (`parent_id`),
  KEY `index_categories_on_friendly_param` (`friendly_param`),
  CONSTRAINT `categories_categories_id_fk` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `competition_event_memberships`
--

DROP TABLE IF EXISTS `competition_event_memberships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `competition_event_memberships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `competition_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `points_factor` float DEFAULT '1',
  `notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_competition_event_memberships_on_competition_id` (`competition_id`),
  KEY `index_competition_event_memberships_on_event_id` (`event_id`),
  CONSTRAINT `competition_event_memberships_competitions_id_fk` FOREIGN KEY (`competition_id`) REFERENCES `events` (`id`) ON DELETE CASCADE,
  CONSTRAINT `competition_event_memberships_events_id_fk` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `discipline_aliases`
--

DROP TABLE IF EXISTS `discipline_aliases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `discipline_aliases` (
  `discipline_id` int(11) NOT NULL DEFAULT '0',
  `alias` varchar(64) NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  KEY `idx_alias` (`alias`),
  KEY `idx_discipline_id` (`discipline_id`),
  CONSTRAINT `discipline_aliases_disciplines_id_fk` FOREIGN KEY (`discipline_id`) REFERENCES `disciplines` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `discipline_bar_categories`
--

DROP TABLE IF EXISTS `discipline_bar_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `discipline_bar_categories` (
  `category_id` int(11) NOT NULL DEFAULT '0',
  `discipline_id` int(11) NOT NULL DEFAULT '0',
  UNIQUE KEY `discipline_bar_categories_category_id_index` (`category_id`,`discipline_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_discipline_id` (`discipline_id`),
  CONSTRAINT `discipline_bar_categories_categories_id_fk` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `discipline_bar_categories_disciplines_id_fk` FOREIGN KEY (`discipline_id`) REFERENCES `disciplines` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `disciplines`
--

DROP TABLE IF EXISTS `disciplines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `disciplines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL DEFAULT '',
  `bar` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `numbers` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_disciplines_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `duplicates`
--

DROP TABLE IF EXISTS `duplicates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `duplicates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `new_attributes` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `duplicates_people`
--

DROP TABLE IF EXISTS `duplicates_people`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `duplicates_people` (
  `person_id` int(11) DEFAULT NULL,
  `duplicate_id` int(11) DEFAULT NULL,
  UNIQUE KEY `index_duplicates_racers_on_racer_id_and_duplicate_id` (`person_id`,`duplicate_id`),
  KEY `index_duplicates_racers_on_racer_id` (`person_id`),
  KEY `index_duplicates_racers_on_duplicate_id` (`duplicate_id`),
  CONSTRAINT `duplicates_people_person_id` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE,
  CONSTRAINT `duplicates_racers_duplicates_id_fk` FOREIGN KEY (`duplicate_id`) REFERENCES `duplicates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `editor_requests`
--

DROP TABLE IF EXISTS `editor_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `editor_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) NOT NULL,
  `editor_id` int(11) NOT NULL,
  `expires_at` datetime NOT NULL,
  `token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_editor_requests_on_editor_id_and_person_id` (`editor_id`,`person_id`),
  KEY `index_editor_requests_on_editor_id` (`editor_id`),
  KEY `index_editor_requests_on_person_id` (`person_id`),
  KEY `index_editor_requests_on_expires_at` (`expires_at`),
  KEY `index_editor_requests_on_token` (`token`),
  CONSTRAINT `editor_requests_ibfk_1` FOREIGN KEY (`editor_id`) REFERENCES `people` (`id`) ON DELETE CASCADE,
  CONSTRAINT `editor_requests_ibfk_2` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `editors_events`
--

DROP TABLE IF EXISTS `editors_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `editors_events` (
  `event_id` int(11) NOT NULL,
  `editor_id` int(11) NOT NULL,
  KEY `index_editors_events_on_event_id` (`event_id`),
  KEY `index_editors_events_on_editor_id` (`editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `city` varchar(128) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `discipline` varchar(32) DEFAULT NULL,
  `flyer` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `notes` varchar(255) DEFAULT '',
  `sanctioned_by` varchar(255) DEFAULT NULL,
  `state` varchar(64) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `flyer_approved` tinyint(1) NOT NULL DEFAULT '0',
  `cancelled` tinyint(1) DEFAULT '0',
  `notification` tinyint(1) DEFAULT '1',
  `number_issuer_id` int(11) DEFAULT NULL,
  `first_aid_provider` varchar(255) DEFAULT NULL,
  `pre_event_fees` float DEFAULT NULL,
  `post_event_fees` float DEFAULT NULL,
  `flyer_ad_fee` float DEFAULT NULL,
  `prize_list` varchar(255) DEFAULT NULL,
  `velodrome_id` int(11) DEFAULT NULL,
  `time` varchar(255) DEFAULT NULL,
  `instructional` tinyint(1) DEFAULT '0',
  `practice` tinyint(1) DEFAULT '0',
  `atra_points_series` tinyint(1) NOT NULL DEFAULT '0',
  `bar_points` int(11) NOT NULL,
  `ironman` tinyint(1) NOT NULL,
  `auto_combined_results` tinyint(1) NOT NULL DEFAULT '1',
  `team_id` int(11) DEFAULT NULL,
  `sanctioning_org_event_id` varchar(16) DEFAULT NULL,
  `promoter_id` int(11) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `postponed` tinyint(1) NOT NULL DEFAULT '0',
  `chief_referee` varchar(255) DEFAULT NULL,
  `beginner_friendly` tinyint(1) NOT NULL DEFAULT '0',
  `website` varchar(255) DEFAULT NULL,
  `registration_link` varchar(255) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  `end_date` date NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_disciplined` (`discipline`),
  KEY `parent_id` (`parent_id`),
  KEY `idx_type` (`type`),
  KEY `events_number_issuer_id_index` (`number_issuer_id`),
  KEY `velodrome_id` (`velodrome_id`),
  KEY `index_events_on_type` (`type`),
  KEY `idx_date` (`date`),
  KEY `index_events_on_sanctioned_by` (`sanctioned_by`),
  KEY `index_events_on_bar_points` (`bar_points`),
  KEY `index_events_on_promoter_id` (`promoter_id`),
  KEY `index_events_on_region_id` (`region_id`),
  CONSTRAINT `events_events_id_fk` FOREIGN KEY (`parent_id`) REFERENCES `events` (`id`) ON DELETE CASCADE,
  CONSTRAINT `events_number_issuers_id_fk` FOREIGN KEY (`number_issuer_id`) REFERENCES `number_issuers` (`id`),
  CONSTRAINT `events_promoter_id` FOREIGN KEY (`promoter_id`) REFERENCES `people` (`id`) ON DELETE SET NULL,
  CONSTRAINT `events_velodrome_id_fk` FOREIGN KEY (`velodrome_id`) REFERENCES `velodromes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `homes`
--

DROP TABLE IF EXISTS `homes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `homes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `photo_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `weeks_of_recent_results` int(11) NOT NULL DEFAULT '2',
  `weeks_of_upcoming_events` int(11) NOT NULL DEFAULT '2',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `import_files`
--

DROP TABLE IF EXISTS `import_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `import_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mailing_lists`
--

DROP TABLE IF EXISTS `mailing_lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mailing_lists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `friendly_name` varchar(255) NOT NULL DEFAULT '',
  `subject_line_prefix` varchar(255) NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`id`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `names`
--

DROP TABLE IF EXISTS `names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nameable_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `year` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `nameable_type` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `team_id` (`nameable_id`),
  KEY `index_names_on_name` (`name`),
  KEY `index_names_on_year` (`year`),
  KEY `index_names_on_nameable_type` (`nameable_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `number_issuers`
--

DROP TABLE IF EXISTS `number_issuers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `number_issuers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `number_issuers_name_index` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pages`
--

DROP TABLE IF EXISTS `pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `body` text NOT NULL,
  `path` varchar(255) NOT NULL DEFAULT '',
  `slug` varchar(255) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_pages_on_path` (`path`),
  KEY `parent_id` (`parent_id`),
  KEY `index_pages_on_slug` (`slug`),
  CONSTRAINT `pages_parent_id_fk` FOREIGN KEY (`parent_id`) REFERENCES `pages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `people`
--

DROP TABLE IF EXISTS `people`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `people` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(64) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `city` varchar(128) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `license` varchar(64) DEFAULT NULL,
  `notes` text,
  `state` varchar(64) DEFAULT NULL,
  `team_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `cell_fax` varchar(255) DEFAULT NULL,
  `ccx_category` varchar(255) DEFAULT NULL,
  `dh_category` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `gender` varchar(2) DEFAULT NULL,
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
  `ccx_only` tinyint(1) NOT NULL DEFAULT '0',
  `bmx_category` varchar(255) DEFAULT NULL,
  `wants_email` tinyint(1) NOT NULL DEFAULT '0',
  `wants_mail` tinyint(1) NOT NULL DEFAULT '0',
  `volunteer_interest` tinyint(1) NOT NULL DEFAULT '0',
  `official_interest` tinyint(1) NOT NULL DEFAULT '0',
  `race_promotion_interest` tinyint(1) NOT NULL DEFAULT '0',
  `team_interest` tinyint(1) NOT NULL DEFAULT '0',
  `member_usac_to` date DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `crypted_password` varchar(255) DEFAULT NULL,
  `password_salt` varchar(255) DEFAULT NULL,
  `persistence_token` varchar(255) DEFAULT NULL,
  `single_access_token` varchar(255) DEFAULT NULL,
  `perishable_token` varchar(255) DEFAULT NULL,
  `login_count` int(11) NOT NULL DEFAULT '0',
  `failed_login_count` int(11) NOT NULL DEFAULT '0',
  `current_login_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `current_login_ip` varchar(255) DEFAULT NULL,
  `last_login_ip` varchar(255) DEFAULT NULL,
  `login` varchar(100) DEFAULT NULL,
  `license_expiration_date` date DEFAULT NULL,
  `club_name` varchar(255) DEFAULT NULL,
  `ncca_club_name` varchar(255) DEFAULT NULL,
  `emergency_contact` varchar(255) DEFAULT NULL,
  `emergency_contact_phone` varchar(255) DEFAULT NULL,
  `card_printed_at` datetime DEFAULT NULL,
  `license_type` varchar(255) DEFAULT NULL,
  `country_code` varchar(2) DEFAULT 'US',
  `membership_card` tinyint(1) NOT NULL DEFAULT '0',
  `official` tinyint(1) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `idx_last_name` (`last_name`),
  KEY `idx_first_name` (`first_name`),
  KEY `idx_team_id` (`team_id`),
  KEY `index_racers_on_member_to` (`member_to`),
  KEY `index_racers_on_member_from` (`member_from`),
  KEY `index_people_on_crypted_password` (`crypted_password`),
  KEY `index_people_on_persistence_token` (`persistence_token`),
  KEY `index_people_on_perishable_token` (`perishable_token`),
  KEY `index_people_on_single_access_token` (`single_access_token`),
  KEY `index_people_on_email` (`email`),
  KEY `index_people_on_license` (`license`),
  KEY `index_people_on_print_card` (`print_card`),
  KEY `index_people_on_login` (`login`),
  KEY `index_people_on_name` (`name`),
  CONSTRAINT `people_team_id_fk` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `people_people`
--

DROP TABLE IF EXISTS `people_people`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `people_people` (
  `person_id` int(11) NOT NULL,
  `editor_id` int(11) NOT NULL,
  UNIQUE KEY `index_people_people_on_editor_id_and_person_id` (`editor_id`,`person_id`),
  KEY `index_people_people_on_editor_id` (`editor_id`),
  KEY `index_people_people_on_person_id` (`person_id`),
  CONSTRAINT `people_people_ibfk_1` FOREIGN KEY (`editor_id`) REFERENCES `people` (`id`) ON DELETE CASCADE,
  CONSTRAINT `people_people_ibfk_2` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `people_roles`
--

DROP TABLE IF EXISTS `people_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `people_roles` (
  `role_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  KEY `role_id` (`role_id`),
  KEY `index_people_roles_on_person_id` (`person_id`),
  CONSTRAINT `people_roles_person_id` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE,
  CONSTRAINT `roles_users_role_id_fk` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `photos`
--

DROP TABLE IF EXISTS `photos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `photos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `caption` text COLLATE utf8_unicode_ci,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `link` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `post_texts`
--

DROP TABLE IF EXISTS `post_texts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `post_texts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) NOT NULL,
  `text` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_post_texts_on_post_id` (`post_id`),
  FULLTEXT KEY `post_text` (`text`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `posts`
--

DROP TABLE IF EXISTS `posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `body` text NOT NULL,
  `date` datetime NOT NULL,
  `subject` varchar(255) NOT NULL DEFAULT '',
  `topica_message_id` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `mailing_list_id` int(11) NOT NULL DEFAULT '0',
  `position` int(11) DEFAULT NULL,
  `from_name` varchar(255) DEFAULT NULL,
  `from_email` varchar(255) DEFAULT NULL,
  `last_reply_at` datetime DEFAULT NULL,
  `last_reply_from_name` varchar(255) DEFAULT NULL,
  `original_id` int(11) DEFAULT NULL,
  `replies_count` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_topica_message_id` (`topica_message_id`),
  KEY `idx_date` (`date`),
  KEY `idx_subject` (`subject`),
  KEY `idx_mailing_list_id` (`mailing_list_id`),
  KEY `idx_date_list` (`date`,`mailing_list_id`),
  KEY `index_posts_on_position` (`position`),
  KEY `index_posts_on_original_id` (`original_id`),
  KEY `index_posts_on_last_reply_at` (`last_reply_at`),
  CONSTRAINT `posts_mailing_list_id_fk` FOREIGN KEY (`mailing_list_id`) REFERENCES `mailing_lists` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `race_numbers`
--

DROP TABLE IF EXISTS `race_numbers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `race_numbers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) NOT NULL DEFAULT '0',
  `discipline_id` int(11) NOT NULL DEFAULT '0',
  `number_issuer_id` int(11) NOT NULL DEFAULT '0',
  `value` varchar(255) NOT NULL DEFAULT '',
  `year` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `racer_id` (`person_id`),
  KEY `discipline_id` (`discipline_id`),
  KEY `number_issuer_id` (`number_issuer_id`),
  KEY `race_numbers_value_index` (`value`),
  KEY `index_race_numbers_on_year` (`year`),
  CONSTRAINT `race_numbers_discipline_id_fk` FOREIGN KEY (`discipline_id`) REFERENCES `disciplines` (`id`),
  CONSTRAINT `race_numbers_number_issuer_id_fk` FOREIGN KEY (`number_issuer_id`) REFERENCES `number_issuers` (`id`),
  CONSTRAINT `race_numbers_person_id` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `races`
--

DROP TABLE IF EXISTS `races`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `races` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) NOT NULL,
  `city` varchar(128) DEFAULT NULL,
  `distance` varchar(255) DEFAULT NULL,
  `state` varchar(64) DEFAULT NULL,
  `field_size` int(11) DEFAULT NULL,
  `laps` int(11) DEFAULT NULL,
  `time` float DEFAULT NULL,
  `finishers` int(11) DEFAULT NULL,
  `notes` varchar(255) DEFAULT '',
  `sanctioned_by` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `result_columns` varchar(255) DEFAULT NULL,
  `bar_points` int(11) DEFAULT NULL,
  `event_id` int(11) NOT NULL,
  `custom_columns` text,
  PRIMARY KEY (`id`),
  KEY `idx_category_id` (`category_id`),
  KEY `index_races_on_event_id` (`event_id`),
  KEY `index_races_on_bar_points` (`bar_points`),
  CONSTRAINT `races_category_id_fk` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `races_event_id_fk` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `racing_associations`
--

DROP TABLE IF EXISTS `racing_associations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `racing_associations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `add_members_from_results` tinyint(1) NOT NULL DEFAULT '1',
  `always_insert_table_headers` tinyint(1) NOT NULL DEFAULT '1',
  `award_cat4_participation_points` tinyint(1) NOT NULL DEFAULT '1',
  `bmx_numbers` tinyint(1) NOT NULL DEFAULT '0',
  `cx_memberships` tinyint(1) NOT NULL DEFAULT '0',
  `eager_match_on_license` tinyint(1) NOT NULL DEFAULT '0',
  `flyers_in_new_window` tinyint(1) NOT NULL DEFAULT '0',
  `gender_specific_numbers` tinyint(1) NOT NULL DEFAULT '0',
  `include_multiday_events_on_schedule` tinyint(1) NOT NULL DEFAULT '0',
  `show_all_teams_on_public_page` tinyint(1) NOT NULL DEFAULT '0',
  `show_calendar_view` tinyint(1) NOT NULL DEFAULT '1',
  `show_events_velodrome` tinyint(1) NOT NULL DEFAULT '1',
  `show_license` tinyint(1) NOT NULL DEFAULT '1',
  `show_only_association_sanctioned_races_on_calendar` tinyint(1) NOT NULL DEFAULT '1',
  `show_practices_on_calendar` tinyint(1) NOT NULL DEFAULT '0',
  `ssl` tinyint(1) NOT NULL DEFAULT '0',
  `usac_results_format` tinyint(1) NOT NULL DEFAULT '0',
  `cat4_womens_race_series_category_id` int(11) DEFAULT NULL,
  `masters_age` int(11) NOT NULL DEFAULT '35',
  `rental_numbers_end` int(11) DEFAULT '99',
  `rental_numbers_start` int(11) DEFAULT '51',
  `search_results_limit` int(11) NOT NULL DEFAULT '100',
  `cat4_womens_race_series_points` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `administrator_tabs` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `competitions` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country_code` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'US',
  `default_discipline` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Road',
  `default_sanctioned_by` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'scott.willson@gmail.com',
  `exempt_team_categories` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  `membership_email` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'scott.willson@gmail.com',
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Cascadia Bicycle Racing Association',
  `rails_host` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'localhost:3000',
  `sanctioning_organizations` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `short_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'CBRA',
  `show_events_sanctioning_org_event_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  `state` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'OR',
  `static_host` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'localhost',
  `usac_region` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'North West',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `cat4_womens_race_series_end_date` date DEFAULT NULL,
  `unregistered_teams_in_results` tinyint(1) NOT NULL DEFAULT '1',
  `next_year_start_at` date DEFAULT NULL,
  `mobile_site` tinyint(1) NOT NULL DEFAULT '0',
  `cat4_womens_race_series_start_date` date DEFAULT NULL,
  `filter_schedule_by_sanctioning_organization` tinyint(1) NOT NULL DEFAULT '0',
  `result_questions_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `filter_schedule_by_region` tinyint(1) NOT NULL DEFAULT '0',
  `default_region_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `regions`
--

DROP TABLE IF EXISTS `regions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `regions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `friendly_param` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_regions_on_name` (`name`),
  UNIQUE KEY `index_regions_on_friendly_param` (`friendly_param`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `results`
--

DROP TABLE IF EXISTS `results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `results` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `race_id` int(11) NOT NULL,
  `team_id` int(11) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `city` varchar(128) DEFAULT NULL,
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
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `time_total` double DEFAULT NULL,
  `laps` int(11) DEFAULT NULL,
  `members_only_place` varchar(8) DEFAULT NULL,
  `points_bonus` int(11) NOT NULL DEFAULT '0',
  `points_penalty` int(11) NOT NULL DEFAULT '0',
  `preliminary` tinyint(1) DEFAULT NULL,
  `bar` tinyint(1) DEFAULT '1',
  `gender` varchar(8) DEFAULT NULL,
  `category_class` varchar(16) DEFAULT NULL,
  `age_group` varchar(16) DEFAULT NULL,
  `custom_attributes` text,
  `competition_result` tinyint(1) NOT NULL,
  `team_competition_result` tinyint(1) NOT NULL,
  `category_name` varchar(255) DEFAULT NULL,
  `event_date_range_s` varchar(255) NOT NULL,
  `date` date NOT NULL,
  `event_end_date` date NOT NULL,
  `event_id` int(11) NOT NULL,
  `event_full_name` varchar(255) NOT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `race_name` varchar(255) NOT NULL,
  `race_full_name` varchar(255) NOT NULL,
  `team_name` varchar(255) DEFAULT NULL,
  `year` int(11) NOT NULL,
  `team_member` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_race_id` (`race_id`),
  KEY `idx_racer_id` (`person_id`),
  KEY `idx_team_id` (`team_id`),
  KEY `index_results_on_place` (`place`),
  KEY `index_results_on_members_only_place` (`members_only_place`),
  KEY `index_results_on_event_id` (`event_id`),
  KEY `index_results_on_year` (`year`),
  CONSTRAINT `results_category_id_fk` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `results_person_id` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`),
  CONSTRAINT `results_race_id_fk` FOREIGN KEY (`race_id`) REFERENCES `races` (`id`) ON DELETE CASCADE,
  CONSTRAINT `results_team_id_fk` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scores`
--

DROP TABLE IF EXISTS `scores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `competition_result_id` int(11) DEFAULT NULL,
  `source_result_id` int(11) DEFAULT NULL,
  `points` float DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `date` date DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `event_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `scores_competition_result_id_index` (`competition_result_id`),
  KEY `scores_source_result_id_index` (`source_result_id`),
  CONSTRAINT `scores_competition_result_id_fk` FOREIGN KEY (`competition_result_id`) REFERENCES `results` (`id`) ON DELETE CASCADE,
  CONSTRAINT `scores_source_result_id_fk` FOREIGN KEY (`source_result_id`) REFERENCES `results` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `teams`
--

DROP TABLE IF EXISTS `teams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `city` varchar(128) DEFAULT NULL,
  `state` varchar(64) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `member` tinyint(1) DEFAULT '0',
  `website` varchar(255) DEFAULT NULL,
  `sponsors` varchar(1000) DEFAULT NULL,
  `contact_name` varchar(255) DEFAULT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  `contact_phone` varchar(255) DEFAULT NULL,
  `show_on_public_page` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `velodromes`
--

DROP TABLE IF EXISTS `velodromes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `velodromes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_velodromes_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `versions`
--

DROP TABLE IF EXISTS `versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `versioned_id` int(11) DEFAULT NULL,
  `versioned_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `modifications` text COLLATE utf8_unicode_ci,
  `number` int(11) DEFAULT NULL,
  `tag` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `reverted_from` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_versions_on_versioned_id_and_versioned_type` (`versioned_id`,`versioned_type`),
  KEY `index_versions_on_user_id_and_user_type` (`user_id`,`user_type`),
  KEY `index_versions_on_user_name` (`user_name`),
  KEY `index_versions_on_number` (`number`),
  KEY `index_versions_on_tag` (`tag`),
  KEY `index_versions_on_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-05-22 22:03:58
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

INSERT INTO schema_migrations (version) VALUES ('20090212200352');

INSERT INTO schema_migrations (version) VALUES ('20090217170845');

INSERT INTO schema_migrations (version) VALUES ('20090217170956');

INSERT INTO schema_migrations (version) VALUES ('20090217212657');

INSERT INTO schema_migrations (version) VALUES ('20090217212924');

INSERT INTO schema_migrations (version) VALUES ('20090224224826');

INSERT INTO schema_migrations (version) VALUES ('20090225004224');

INSERT INTO schema_migrations (version) VALUES ('20090305222446');

INSERT INTO schema_migrations (version) VALUES ('20090310155100');

INSERT INTO schema_migrations (version) VALUES ('20090310155105');

INSERT INTO schema_migrations (version) VALUES ('20090312003519');

INSERT INTO schema_migrations (version) VALUES ('20090313231845');

INSERT INTO schema_migrations (version) VALUES ('20090316162742');

INSERT INTO schema_migrations (version) VALUES ('20090324032935');

INSERT INTO schema_migrations (version) VALUES ('20090326190925');

INSERT INTO schema_migrations (version) VALUES ('20090326192755');

INSERT INTO schema_migrations (version) VALUES ('20090328185643');

INSERT INTO schema_migrations (version) VALUES ('20090409205042');

INSERT INTO schema_migrations (version) VALUES ('20090422162313');

INSERT INTO schema_migrations (version) VALUES ('20090422173446');

INSERT INTO schema_migrations (version) VALUES ('20090423002956');

INSERT INTO schema_migrations (version) VALUES ('20090504040327');

INSERT INTO schema_migrations (version) VALUES ('20090504040328');

INSERT INTO schema_migrations (version) VALUES ('20090505151122');

INSERT INTO schema_migrations (version) VALUES ('20090514202305');

INSERT INTO schema_migrations (version) VALUES ('20090515031733');

INSERT INTO schema_migrations (version) VALUES ('20090519034739');

INSERT INTO schema_migrations (version) VALUES ('20090528023747');

INSERT INTO schema_migrations (version) VALUES ('20090604213033');

INSERT INTO schema_migrations (version) VALUES ('20090606004452');

INSERT INTO schema_migrations (version) VALUES ('20090606191333');

INSERT INTO schema_migrations (version) VALUES ('20090607004047');

INSERT INTO schema_migrations (version) VALUES ('20090611215912');

INSERT INTO schema_migrations (version) VALUES ('20090620000926');

INSERT INTO schema_migrations (version) VALUES ('20090621233142');

INSERT INTO schema_migrations (version) VALUES ('20090623033141');

INSERT INTO schema_migrations (version) VALUES ('20090624002909');

INSERT INTO schema_migrations (version) VALUES ('20090707152828');

INSERT INTO schema_migrations (version) VALUES ('20090708162116');

INSERT INTO schema_migrations (version) VALUES ('20090708162118');

INSERT INTO schema_migrations (version) VALUES ('20090730022816');

INSERT INTO schema_migrations (version) VALUES ('20090815135542');

INSERT INTO schema_migrations (version) VALUES ('20090930060618');

INSERT INTO schema_migrations (version) VALUES ('20091006194727');

INSERT INTO schema_migrations (version) VALUES ('20091007232822');

INSERT INTO schema_migrations (version) VALUES ('20091009021956');

INSERT INTO schema_migrations (version) VALUES ('20091011235631');

INSERT INTO schema_migrations (version) VALUES ('20091015052458');

INSERT INTO schema_migrations (version) VALUES ('20091122223629');

INSERT INTO schema_migrations (version) VALUES ('20091129235114');

INSERT INTO schema_migrations (version) VALUES ('20091201031927');

INSERT INTO schema_migrations (version) VALUES ('20091220162338');

INSERT INTO schema_migrations (version) VALUES ('20100107001744');

INSERT INTO schema_migrations (version) VALUES ('20100113032309');

INSERT INTO schema_migrations (version) VALUES ('20100121041557');

INSERT INTO schema_migrations (version) VALUES ('20100210042552');

INSERT INTO schema_migrations (version) VALUES ('20100211042204');

INSERT INTO schema_migrations (version) VALUES ('20100320020606');

INSERT INTO schema_migrations (version) VALUES ('20100320224529');

INSERT INTO schema_migrations (version) VALUES ('20100406002503');

INSERT INTO schema_migrations (version) VALUES ('20100407222156');

INSERT INTO schema_migrations (version) VALUES ('20100511224150');

INSERT INTO schema_migrations (version) VALUES ('20100601154817');

INSERT INTO schema_migrations (version) VALUES ('20100608160458');

INSERT INTO schema_migrations (version) VALUES ('20100613014859');

INSERT INTO schema_migrations (version) VALUES ('20100613220247');

INSERT INTO schema_migrations (version) VALUES ('20100616224058');

INSERT INTO schema_migrations (version) VALUES ('20100616230454');

INSERT INTO schema_migrations (version) VALUES ('20100701032620');

INSERT INTO schema_migrations (version) VALUES ('20100831151754');

INSERT INTO schema_migrations (version) VALUES ('20100905013917');

INSERT INTO schema_migrations (version) VALUES ('20100920160034');

INSERT INTO schema_migrations (version) VALUES ('20100924041956');

INSERT INTO schema_migrations (version) VALUES ('20100924161426');

INSERT INTO schema_migrations (version) VALUES ('20110219031339');

INSERT INTO schema_migrations (version) VALUES ('20110328232024');

INSERT INTO schema_migrations (version) VALUES ('20110329233050');

INSERT INTO schema_migrations (version) VALUES ('20110521233707');

INSERT INTO schema_migrations (version) VALUES ('20110618232719');

INSERT INTO schema_migrations (version) VALUES ('20110806162623');

INSERT INTO schema_migrations (version) VALUES ('20110922012402');

INSERT INTO schema_migrations (version) VALUES ('20111008220748');

INSERT INTO schema_migrations (version) VALUES ('20111121165105');

INSERT INTO schema_migrations (version) VALUES ('20111124233132');

INSERT INTO schema_migrations (version) VALUES ('20111218163759');

INSERT INTO schema_migrations (version) VALUES ('20111218301508');

INSERT INTO schema_migrations (version) VALUES ('20120205200408');

INSERT INTO schema_migrations (version) VALUES ('20120211045337');

INSERT INTO schema_migrations (version) VALUES ('20120301051824');

INSERT INTO schema_migrations (version) VALUES ('20120528182244');

INSERT INTO schema_migrations (version) VALUES ('20120720235539');

INSERT INTO schema_migrations (version) VALUES ('20121002174208');

INSERT INTO schema_migrations (version) VALUES ('20130418150015');

INSERT INTO schema_migrations (version) VALUES ('20130424203721');

INSERT INTO schema_migrations (version) VALUES ('20130515151312');

INSERT INTO schema_migrations (version) VALUES ('20130515151637');

INSERT INTO schema_migrations (version) VALUES ('20130522185756');

INSERT INTO schema_migrations (version) VALUES ('20130730202355');

INSERT INTO schema_migrations (version) VALUES ('20130731195457');

INSERT INTO schema_migrations (version) VALUES ('20130802174740');

INSERT INTO schema_migrations (version) VALUES ('20130802185855');

INSERT INTO schema_migrations (version) VALUES ('20130820170738');

INSERT INTO schema_migrations (version) VALUES ('20130913164501');

INSERT INTO schema_migrations (version) VALUES ('20131015142703');

INSERT INTO schema_migrations (version) VALUES ('20131113143051');

INSERT INTO schema_migrations (version) VALUES ('20131126150417');

INSERT INTO schema_migrations (version) VALUES ('20131215151535');

INSERT INTO schema_migrations (version) VALUES ('20140207223552');

INSERT INTO schema_migrations (version) VALUES ('20140211232628');

INSERT INTO schema_migrations (version) VALUES ('20140214002555');

INSERT INTO schema_migrations (version) VALUES ('20140303223128');

INSERT INTO schema_migrations (version) VALUES ('20140304153913');

INSERT INTO schema_migrations (version) VALUES ('20140306011719');

INSERT INTO schema_migrations (version) VALUES ('20140306165856');

INSERT INTO schema_migrations (version) VALUES ('20140319234206');

INSERT INTO schema_migrations (version) VALUES ('20140325180308');

INSERT INTO schema_migrations (version) VALUES ('20140326210703');

INSERT INTO schema_migrations (version) VALUES ('20140327214203');

INSERT INTO schema_migrations (version) VALUES ('20140330010812');

INSERT INTO schema_migrations (version) VALUES ('20140330145224');

INSERT INTO schema_migrations (version) VALUES ('20140401041601');

INSERT INTO schema_migrations (version) VALUES ('20140403051211');

INSERT INTO schema_migrations (version) VALUES ('20140415022407');

INSERT INTO schema_migrations (version) VALUES ('20140430213503');

INSERT INTO schema_migrations (version) VALUES ('20140523033604');

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

