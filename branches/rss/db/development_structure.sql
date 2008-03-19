CREATE TABLE `activities` (
  `id` int(11) NOT NULL auto_increment,
  `comments` text,
  `date` date NOT NULL,
  `minutes` int(11) NOT NULL default '0',
  `project_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `invoice_id` int(11) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_activities_on_project_id` (`project_id`),
  KEY `index_activities_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

CREATE TABLE `clients` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `is_inactive` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_clients_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

CREATE TABLE `clients_logins` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `client_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_clients_logins_on_login` (`login`),
  KEY `index_clients_logins_on_client_id` (`client_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

CREATE TABLE `invoices` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `notes` text,
  `client_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime default NULL,
  `is_issued` tinyint(1) NOT NULL default '0',
  `issued_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_invoices_on_name` (`name`),
  KEY `index_invoices_on_client_id` (`client_id`),
  KEY `index_invoices_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

CREATE TABLE `password_codes` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL,
  `code` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `projects` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `description` text,
  `client_id` int(11) NOT NULL,
  `is_inactive` tinyint(1) NOT NULL default '0',
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_projects_on_name` (`name`),
  KEY `index_projects_on_client_id` (`client_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `roles` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `short_name` varchar(5) NOT NULL,
  `is_admin` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_roles_on_name` (`name`),
  UNIQUE KEY `index_roles_on_short_name` (`short_name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `login_key` varchar(255) default NULL,
  `role_id` int(11) NOT NULL,
  `is_inactive` tinyint(1) NOT NULL default '0',
  `salt` varchar(255) NOT NULL,
  `password_code` varchar(255) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_users_on_login` (`login`),
  KEY `index_users_on_role_id` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

INSERT INTO `schema_info` (version) VALUES (4)