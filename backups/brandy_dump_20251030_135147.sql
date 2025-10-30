-- MySQL dump 10.13  Distrib 5.7.24, for osx11.1 (x86_64)
--
-- Host: localhost    Database: brandy
-- ------------------------------------------------------
-- Server version	9.1.0

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
-- Table structure for table `cached_searches`
--

DROP TABLE IF EXISTS `cached_searches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cached_searches` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `query` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `search_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` int DEFAULT NULL,
  `results` json NOT NULL,
  `hit_count` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NULL DEFAULT NULL,
  `last_accessed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_cached_searches_unique` (`query`,`search_type`,`category`),
  KEY `idx_cached_searches_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cached_searches`
--

LOCK TABLES `cached_searches` WRITE;
/*!40000 ALTER TABLE `cached_searches` DISABLE KEYS */;
/*!40000 ALTER TABLE `cached_searches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `events` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `event_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `session_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `referrer` text COLLATE utf8mb4_unicode_ci,
  `metadata` json DEFAULT (_utf8mb4'{}'),
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_events_user_id` (`user_id`),
  KEY `idx_events_event_type` (`event_type`),
  KEY `idx_events_created_at` (`created_at`),
  KEY `idx_events_session_id` (`session_id`),
  CONSTRAINT `events_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `events`
--

LOCK TABLES `events` WRITE;
/*!40000 ALTER TABLE `events` DISABLE KEYS */;
INSERT INTO `events` VALUES ('532e19b6-b41c-11f0-8ee4-ced2aff6c4f2',NULL,'form_submission','Brief Brandy Form Submitted','127.0.0.1',NULL,NULL,NULL,'{\"source\": \"landing_page\"}','2025-10-28 16:36:59'),('b2a33b1e-b382-11f0-8ee4-ced2aff6c4f2',NULL,'form_submission','Brief Brandy Form Submitted','127.0.0.1',NULL,NULL,NULL,'{\"source\": \"landing_page\"}','2025-10-27 22:17:17');
/*!40000 ALTER TABLE `events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_answers`
--

DROP TABLE IF EXISTS `form_answers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_answers` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `submission_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `field_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `field_value` text COLLATE utf8mb4_unicode_ci,
  `field_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `field_order` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_form_answers_submission_id` (`submission_id`),
  KEY `idx_form_answers_field_name` (`field_name`),
  CONSTRAINT `form_answers_ibfk_1` FOREIGN KEY (`submission_id`) REFERENCES `form_submissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_answers`
--

LOCK TABLES `form_answers` WRITE;
/*!40000 ALTER TABLE `form_answers` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_answers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_submissions`
--

DROP TABLE IF EXISTS `form_submissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_submissions` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `event_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `form_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'brief_brandy',
  `status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'completed',
  `completion_percentage` int DEFAULT '100',
  `time_spent_seconds` int DEFAULT NULL,
  `submitted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `metadata` json DEFAULT (_utf8mb4'{}'),
  PRIMARY KEY (`id`),
  KEY `idx_form_submissions_user_id` (`user_id`),
  KEY `idx_form_submissions_event_id` (`event_id`),
  KEY `idx_form_submissions_form_type` (`form_type`),
  KEY `idx_form_submissions_submitted_at` (`submitted_at`),
  CONSTRAINT `form_submissions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `form_submissions_ibfk_2` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_submissions`
--

LOCK TABLES `form_submissions` WRITE;
/*!40000 ALTER TABLE `form_submissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_submissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `generated_names`
--

DROP TABLE IF EXISTS `generated_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `generated_names` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `event_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `submission_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `style` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `min_length` int DEFAULT NULL,
  `max_length` int DEFAULT NULL,
  `category` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `probability` float DEFAULT NULL,
  `risk_level` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `scores` json DEFAULT (_utf8mb4'{}'),
  `top_conflicts` json DEFAULT (_utf8mb4'[]'),
  `recommendation` text COLLATE utf8mb4_unicode_ci,
  `is_favorite` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_generated_names_user_id` (`user_id`),
  KEY `idx_generated_names_submission_id` (`submission_id`),
  KEY `idx_generated_names_name` (`name`),
  KEY `idx_generated_names_risk_level` (`risk_level`),
  KEY `idx_generated_names_created_at` (`created_at`),
  KEY `event_id` (`event_id`),
  CONSTRAINT `generated_names_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `generated_names_ibfk_2` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE SET NULL,
  CONSTRAINT `generated_names_ibfk_3` FOREIGN KEY (`submission_id`) REFERENCES `form_submissions` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `generated_names`
--

LOCK TABLES `generated_names` WRITE;
/*!40000 ALTER TABLE `generated_names` DISABLE KEYS */;
/*!40000 ALTER TABLE `generated_names` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `similarity_checks`
--

DROP TABLE IF EXISTS `similarity_checks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `similarity_checks` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `event_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name1` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name2` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phonetic_score` float DEFAULT NULL,
  `spelling_score` float DEFAULT NULL,
  `visual_score` float DEFAULT NULL,
  `overall_score` float DEFAULT NULL,
  `is_conflict` tinyint(1) DEFAULT NULL,
  `algorithm_details` json DEFAULT (_utf8mb4'{}'),
  `checked_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_similarity_checks_user_id` (`user_id`),
  KEY `idx_similarity_checks_name1` (`name1`),
  KEY `idx_similarity_checks_checked_at` (`checked_at`),
  KEY `event_id` (`event_id`),
  CONSTRAINT `similarity_checks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `similarity_checks_ibfk_2` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `similarity_checks`
--

LOCK TABLES `similarity_checks` WRITE;
/*!40000 ALTER TABLE `similarity_checks` DISABLE KEYS */;
/*!40000 ALTER TABLE `similarity_checks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trademark_checks`
--

DROP TABLE IF EXISTS `trademark_checks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trademark_checks` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `event_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` int DEFAULT NULL,
  `search_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `probability` float DEFAULT NULL,
  `risk_level` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `scores` json DEFAULT (_utf8mb4'{}'),
  `conflicts_found` int DEFAULT '0',
  `conflicts` json DEFAULT (_utf8mb4'[]'),
  `checked_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_trademark_checks_user_id` (`user_id`),
  KEY `idx_trademark_checks_name` (`name`),
  KEY `idx_trademark_checks_checked_at` (`checked_at`),
  KEY `event_id` (`event_id`),
  CONSTRAINT `trademark_checks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `trademark_checks_ibfk_2` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trademark_checks`
--

LOCK TABLES `trademark_checks` WRITE;
/*!40000 ALTER TABLE `trademark_checks` DISABLE KEYS */;
/*!40000 ALTER TABLE `trademark_checks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `full_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `metadata` json DEFAULT (_utf8mb4'{}'),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_users_email` (`email`),
  KEY `idx_users_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('b2a2f29e-b382-11f0-8ee4-ced2aff6c4f2','test@example.com','Test User','Test Company',NULL,'Peru','2025-10-27 22:17:17','2025-10-27 22:17:17',NULL,1,'{}');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `v_form_submissions_complete`
--

DROP TABLE IF EXISTS `v_form_submissions_complete`;
/*!50001 DROP VIEW IF EXISTS `v_form_submissions_complete`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_form_submissions_complete` AS SELECT 
 1 AS `submission_id`,
 1 AS `user_id`,
 1 AS `email`,
 1 AS `full_name`,
 1 AS `company_name`,
 1 AS `form_type`,
 1 AS `status`,
 1 AS `completion_percentage`,
 1 AS `time_spent_seconds`,
 1 AS `submitted_at`,
 1 AS `answers`,
 1 AS `metadata`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_popular_names`
--

DROP TABLE IF EXISTS `v_popular_names`;
/*!50001 DROP VIEW IF EXISTS `v_popular_names`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_popular_names` AS SELECT 
 1 AS `name`,
 1 AS `generation_count`,
 1 AS `avg_probability`,
 1 AS `unique_users`,
 1 AS `first_generated`,
 1 AS `last_generated`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_user_activity_summary`
--

DROP TABLE IF EXISTS `v_user_activity_summary`;
/*!50001 DROP VIEW IF EXISTS `v_user_activity_summary`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_user_activity_summary` AS SELECT 
 1 AS `user_id`,
 1 AS `email`,
 1 AS `full_name`,
 1 AS `user_since`,
 1 AS `total_form_submissions`,
 1 AS `total_names_generated`,
 1 AS `total_trademark_checks`,
 1 AS `total_similarity_checks`,
 1 AS `last_activity`,
 1 AS `total_events`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'brandy'
--

--
-- Dumping routines for database 'brandy'
--
/*!50003 DROP PROCEDURE IF EXISTS `clean_expired_cache` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `clean_expired_cache`()
BEGIN DELETE FROM cached_searches WHERE expires_at < NOW(); SELECT ROW_COUNT() AS deleted_count; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `v_form_submissions_complete`
--

/*!50001 DROP VIEW IF EXISTS `v_form_submissions_complete`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_form_submissions_complete` AS select `fs`.`id` AS `submission_id`,`fs`.`user_id` AS `user_id`,`u`.`email` AS `email`,`u`.`full_name` AS `full_name`,`u`.`company_name` AS `company_name`,`fs`.`form_type` AS `form_type`,`fs`.`status` AS `status`,`fs`.`completion_percentage` AS `completion_percentage`,`fs`.`time_spent_seconds` AS `time_spent_seconds`,`fs`.`submitted_at` AS `submitted_at`,json_objectagg(`fa`.`field_name`,json_object('value',`fa`.`field_value`,'type',`fa`.`field_type`)) AS `answers`,`fs`.`metadata` AS `metadata` from ((`form_submissions` `fs` left join `users` `u` on((`fs`.`user_id` = `u`.`id`))) left join `form_answers` `fa` on((`fs`.`id` = `fa`.`submission_id`))) group by `fs`.`id`,`u`.`email`,`u`.`full_name`,`u`.`company_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_popular_names`
--

/*!50001 DROP VIEW IF EXISTS `v_popular_names`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_popular_names` AS select `generated_names`.`name` AS `name`,count(0) AS `generation_count`,avg(`generated_names`.`probability`) AS `avg_probability`,count(distinct `generated_names`.`user_id`) AS `unique_users`,min(`generated_names`.`created_at`) AS `first_generated`,max(`generated_names`.`created_at`) AS `last_generated` from `generated_names` group by `generated_names`.`name` order by `generation_count` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_user_activity_summary`
--

/*!50001 DROP VIEW IF EXISTS `v_user_activity_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_user_activity_summary` AS select `u`.`id` AS `user_id`,`u`.`email` AS `email`,`u`.`full_name` AS `full_name`,`u`.`created_at` AS `user_since`,count(distinct `fs`.`id`) AS `total_form_submissions`,count(distinct `gn`.`id`) AS `total_names_generated`,count(distinct `tc`.`id`) AS `total_trademark_checks`,count(distinct `sc`.`id`) AS `total_similarity_checks`,max(`e`.`created_at`) AS `last_activity`,count(distinct `e`.`id`) AS `total_events` from (((((`users` `u` left join `form_submissions` `fs` on((`u`.`id` = `fs`.`user_id`))) left join `generated_names` `gn` on((`u`.`id` = `gn`.`user_id`))) left join `trademark_checks` `tc` on((`u`.`id` = `tc`.`user_id`))) left join `similarity_checks` `sc` on((`u`.`id` = `sc`.`user_id`))) left join `events` `e` on((`u`.`id` = `e`.`user_id`))) group by `u`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-30 13:51:55
