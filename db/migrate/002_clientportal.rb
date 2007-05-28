#
# Migrations adds functionality of client's portal.
# It changes client model and adds 2 columns:
#   - login (by default its value is first word of client name)
#   - password (by default is client login)
#
# author: Wiktor Gworek
#

class Clientportal < ActiveRecord::Migration
    def self.up
        add_column :clients, :login, :string, :null => false
        add_column :clients, :password, :string, :null => false
        Client.find(:all).each { |client|
            client.login = client.name.scan(/\w+/)[0].strip.downcase
            client.password = Digest::SHA1.hexdigest(client.login)
            client.save
        } 
    end

    def self.down
        remove_column :clients, :login
        remove_column :clients, :password
    end
end

