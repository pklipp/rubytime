class AddPasswordCodeToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :password_code, :string
  end

  def self.down
    remove_column :users, :password_code
  end
end
