-- phpMyAdmin SQL Dump
-- version 2.8.1
-- http://www.phpmyadmin.net
-- 
-- Host: localhost
-- Generation Time: Jul 21, 2006 at 10:03 AM
-- Server version: 5.0.21
-- PHP Version: 5.1.4
-- 
-- Database: `llptt`
-- 

-- --------------------------------------------------------

-- 
-- Table structure for table `activities`
-- 

DROP TABLE IF EXISTS `activities`;
CREATE TABLE `activities` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `comments` text collate latin1_general_ci NOT NULL,
  `date` date NOT NULL default '0000-00-00',
  `minutes` int(11) NOT NULL default '0',
  `project_id` int(11) NOT NULL default '0',
  `user_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci AUTO_INCREMENT=1 ;

-- 
-- Dumping data for table `activities`
-- 


-- --------------------------------------------------------

-- 
-- Table structure for table `clients`
-- 

DROP TABLE IF EXISTS `clients`;
CREATE TABLE `clients` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `name` varchar(100) collate latin1_general_ci NOT NULL default '',
  `description` text collate latin1_general_ci NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci AUTO_INCREMENT=2 ;

-- 
-- Dumping data for table `clients`
-- 

INSERT INTO `clients` VALUES (1, 'Lunar Logic', 'Lunar Logic');

-- --------------------------------------------------------

-- 
-- Table structure for table `projects`
-- 

DROP TABLE IF EXISTS `projects`;
CREATE TABLE `projects` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `name` varchar(255) collate latin1_general_ci NOT NULL default '',
  `description` text collate latin1_general_ci NOT NULL,
  `client_id` int(11) NOT NULL default '0',
  `is_inactive` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci PACK_KEYS=0 AUTO_INCREMENT=2 ;

-- 
-- Dumping data for table `projects`
-- 

INSERT INTO `projects` VALUES (1, 'First Project', 'First project', 1, 0);

-- --------------------------------------------------------

-- 
-- Table structure for table `roles`
-- 

DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `name` varchar(100) collate latin1_general_ci NOT NULL default '',
  `short_name` varchar(5) collate latin1_general_ci NOT NULL default '',
  `is_admin` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `short_name` (`short_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci AUTO_INCREMENT=3 ;

-- 
-- Dumping data for table `roles`
-- 

INSERT INTO `roles` VALUES (1, 'Project Manager', 'PM', 1);
INSERT INTO `roles` VALUES (2, 'Developer', 'DEV', 0);

-- --------------------------------------------------------

-- 
-- Table structure for table `schema_info`
-- 

DROP TABLE IF EXISTS `schema_info`;
CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

-- 
-- Dumping data for table `schema_info`
-- 

INSERT INTO `schema_info` VALUES (5);

-- --------------------------------------------------------

-- 
-- Table structure for table `users`
-- 

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `login` varchar(255) collate latin1_general_ci NOT NULL default '',
  `password` varchar(255) collate latin1_general_ci NOT NULL default '',
  `name` varchar(255) collate latin1_general_ci NOT NULL default '',
  `email` varchar(255) collate latin1_general_ci NOT NULL default '',
  `login_key` varchar(32) collate latin1_general_ci NOT NULL default '',
  `role_id` int(11) NOT NULL default '0',
  `is_inactive` tinyint(1) NOT NULL default '0',
  `salt` varchar(255) collate latin1_general_ci NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `login` (`login`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci AUTO_INCREMENT=2 ;

-- 
-- Dumping data for table `users`
-- 

INSERT INTO `users` VALUES (1, 'admin', '7be43c1935a3d4ccd904a062a0e8925fb986829f', 'admin', 'admin@llp.pl', 'uwetyoiuytowiug3h9874tyiquerytoi', 1, 0, '287560120.570862222928554');
