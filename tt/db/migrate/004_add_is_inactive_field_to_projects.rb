class AddIsInactiveFieldToProjects < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `projects` ADD `is_inactive` BOOL NOT NULL DEFAULT '0'"
  end

  def self.down
    execute "ALTER TABLE `projects` DROP `is_inactive` "
  end
end
