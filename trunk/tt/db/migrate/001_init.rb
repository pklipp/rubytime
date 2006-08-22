class Init < ActiveRecord::Migration
  def self.up
    sql_code = <<-END

-- 
-- Table structure for table `activities`
-- 

CREATE TABLE `activities` (
  `id` int(11) NOT NULL,
  `comments` text NOT NULL,
  `date` date NOT NULL default '0000-00-00',
  `minutes` int(11) NOT NULL default '0',
  `project_id` int(11) NOT NULL default '0',
  `user_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) TYPE=MyISAM ;


-- 
-- Table structure for table `clients`
-- 

CREATE TABLE `clients` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL default '',
  `description` text NOT NULL,
  PRIMARY KEY  (`id`)
) TYPE=InnoDB ;

-- 
-- Dumping data for table `clients`
-- 

INSERT INTO `clients` VALUES (1, 'Lunar Logic', 'Lunar Logic');

-- 
-- Table structure for table `projects`
-- 

CREATE TABLE `projects` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL default '',
  `description` text NOT NULL,
  `client_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) TYPE=MyISAM PACK_KEYS=0 ;

-- 
-- Dumping data for table `projects`
-- 

INSERT INTO `projects` VALUES (1, 'First Project', 'First project', 1);

-- 
-- Table structure for table `roles`
-- 

CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL default '',
  `short_name` varchar(5) NOT NULL default '',
  PRIMARY KEY  (`id`)
) TYPE=MyISAM ;

-- 
-- Dumping data for table `roles`
-- 

INSERT INTO `roles` VALUES (1, 'Project Manager', 'PM');
INSERT INTO `roles` VALUES (2, 'Developer', 'DEV');

-- 
-- Table structure for table `users`
-- 

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `login` varchar(255) NOT NULL default '',
  `password` varchar(255) NOT NULL default '',
  `name` varchar(255) NOT NULL default '',
  `email` varchar(255) NOT NULL default '',
  `login_key` varchar(32) NOT NULL default '',
  `role_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) TYPE=MyISAM ;

-- 
-- Dumping data for table `users`
-- 

INSERT INTO `users` VALUES (1, 'admin', 'admin', 'Admin', 'admin@llp.pl', 'uwetyoiuytowiug3h9874tyiquerytoi', 1);      
--    
    END
    sql_code.split(';').each do |stmt|
      execute stmt
    end
  end

  def self.down
    execute "DROP TABLE `activities`, `clients`, `projects`, `roles`, `users`;"
  end
end
