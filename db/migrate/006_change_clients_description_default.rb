class ChangeClientsDescriptionDefault < ActiveRecord::Migration
  def self.up
    change_column :clients, :description, :text, :null => true, :default => nil
  end

  def self.down
  end
end
