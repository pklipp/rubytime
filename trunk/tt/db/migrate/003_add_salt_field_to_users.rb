class AddSaltFieldToUsers < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `users` ADD `salt` VARCHAR( 255 ) NOT NULL"
  end

  def self.down
    execute "ALTER TABLE `users` DROP `salt` "
  end
end
