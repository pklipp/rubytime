class UpdateDb < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `clients` CHANGE `id` `id` INT( 11 ) UNSIGNED NOT NULL AUTO_INCREMENT" 
    execute "ALTER TABLE `clients` ADD UNIQUE (`name`)"
    execute "ALTER TABLE `activities` CHANGE `id` `id` INT( 11 ) UNSIGNED NOT NULL AUTO_INCREMENT" 
    execute "ALTER TABLE `roles` CHANGE `id` `id` INT( 11 ) UNSIGNED NOT NULL AUTO_INCREMENT "
    execute "ALTER TABLE `roles` ADD UNIQUE (`name`)"
    execute "ALTER TABLE `roles` ADD UNIQUE (`short_name`)"
    execute "ALTER TABLE `roles` ADD `is_admin` BOOL NOT NULL DEFAULT '0'"
    execute "ALTER TABLE `users` ADD `is_inactive` BOOL NOT NULL DEFAULT '0';"  
    execute "ALTER TABLE `users` ADD UNIQUE (`login`)"
    execute "ALTER TABLE `users` CHANGE `id` `id` INT( 11 ) UNSIGNED NOT NULL AUTO_INCREMENT "
    execute "ALTER TABLE `projects` ADD UNIQUE (`name`)"
    execute "ALTER TABLE `projects` CHANGE `id` `id` INT( 11 ) UNSIGNED NOT NULL AUTO_INCREMENT "
  end

  def self.down
    execute "ALTER TABLE `clients` CHANGE `id` `id` INT( 11 ) NOT NULL"
    execute "ALTER TABLE `clients` DROP INDEX `name`"
    execute "ALTER TABLE `activities` CHANGE `id` `id` INT( 11 ) NOT NULL"
    execute "ALTER TABLE `roles` CHANGE `id` `id` INT( 11 ) NOT NULL"
    execute "ALTER TABLE `roles` DROP INDEX `name`"
    execute "ALTER TABLE `roles` DROP INDEX `short_name`"
    execute "ALTER TABLE `roles` DROP `is_admin` "
    execute "ALTER TABLE `users` DROP `is_inactive` "
    execute "ALTER TABLE `users` DROP INDEX `login`"
    execute "ALTER TABLE `users` CHANGE `id` `id` INT( 11 ) NOT NULL"
    execute "ALTER TABLE `projects` DROP INDEX `name`"
    execute "ALTER TABLE `projects` CHANGE `id` `id` INT( 11 ) NOT NULL "
  end
end

