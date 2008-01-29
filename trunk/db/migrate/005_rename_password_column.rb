class RenamePasswordColumn < ActiveRecord::Migration
  def self.up
    #rename_column :clients_logins, :password, :password_hash
    rename_column :users, :password, :password_hash
  end

  def self.down
    rename_column :users, :password_hash, :password
    rename_column :clients_logins, :password_hash, :password
  end
end
