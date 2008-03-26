class CleanUnusedFields < ActiveRecord::Migration
  def self.up
    remove_column :users, :login_key
  end

  def self.down
    add_column :users, :login_key, :string
  end
end
