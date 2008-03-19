class AddCreatedAtToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :created_at, :datetime
    add_column :projects, :created_at, :datetime
    add_column :users, :created_at, :datetime
  end

  def self.down
    remove_column :activities, :created_at
    remove_column :projects, :created_at
    remove_column :users, :created_at
  end
end
