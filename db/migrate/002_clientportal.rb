#
# Migrations adds functionality of client's portal.
# It addes new table clients_logins with columns:
#   - login (unique)
#   - password 
#   - id of client 
#
# author: Wiktor Gworek
#

class Clientportal < ActiveRecord::Migration
  def self.up
    #Adds default charset if mysql
    db_optionts = (ActiveRecord::Base.configurations[RAILS_ENV]['adapter']=="mysql" ? "DEFAULT CHARSET=utf8" : nil)
    
    create_table :clients_logins, :force => true, :options => db_optionts  do |t|
      t.column :login,     :string,  :null => false
      t.column :password,  :string,  :null => false
      t.column :client_id, :integer, :null => false
    end        
    
    add_index :clients_logins, :client_id
    add_index :clients_logins, :login, :unique => true
  end

  def self.down
    drop_table :clients_logins
  end
end

