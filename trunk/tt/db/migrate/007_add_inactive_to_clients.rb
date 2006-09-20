class AddInactiveToClients < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `clients` ADD COLUMN `is_inactive` BOOLEAN NOT NULL DEFAULT 0;"
  end

  def self.down
    execute "ALTER TABLE `clients` DROP COLUMN `is_inactive`"
  end
end
