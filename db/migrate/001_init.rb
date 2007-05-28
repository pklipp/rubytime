class Init < ActiveRecord::Migration
  def self.up
  
    #Adds default charset if mysql
    db_optionts = (ActiveRecord::Base.configurations[RAILS_ENV]['adapter']=="mysql" ? "DEFAULT CHARSET=utf8" : nil)
    
    #Creates table roles.
    create_table :roles, :force => true, :options => db_optionts do |t|
      t.column :name, :string, :null => false
      t.column :short_name, :string, :limit => 5, :null => false
      t.column :is_admin, :boolean, :default => false, :null => false
    end
    add_index :roles, :name, :unique => true
    add_index :roles, :short_name, :unique => true  
    Role.create(:name=> 'Project Manager', :short_name => 'PM', :is_admin => true)
    Role.create(:name=> 'Developer', :short_name => 'DEV')
    
    #Creates table users.
    create_table :users, :force => true, :options => db_optionts do |t|
      t.column :login, :string, :null => false
      t.column :password, :string, :null => false
      t.column :name, :string, :null => false
      t.column :email, :string, :null => false
      t.column :login_key, :string, :null => true
      t.column :role_id, :integer, :null => false
      t.column :is_inactive, :boolean, :default => false, :null => false
      t.column :salt, :string, :null => false
    end
    add_index :users, :role_id
    add_index :users, :login, :unique => true
    User.create(:login => 'admin', :name => 'admin', :email => 'admin@llp.pl', :role_id => 1, :password => '7be43c1935a3d4ccd904a062a0e8925fb986829f', :salt => '287560120.570862222928554')
    
    #Creates table clients.
    create_table :clients, :force => true, :options => db_optionts do |t|
      t.column :name, :string, :null => false
      t.column :description, :text, :null => false
      t.column :is_inactive, :boolean, :default => false, :null => false
    end
    add_index :clients, :name, :unique => true
    Client.create(:name=> 'Lunar Logic', :description => 'Lunar Logic')
  
    #Creates table projects.
    create_table :projects, :force => true, :options => db_optionts do |t|
      t.column :name, :string, :null => false
      t.column :description, :text
      t.column :client_id, :integer, :null => false
      t.column :is_inactive, :boolean, :default => false, :null => false
    end
    add_index :projects, :name, :unique => true
    add_index :projects, :client_id
    Project.create(:name=> 'First Project', :description => 'First Project', :client_id => 1)
  
    #Creates table activities.
    create_table :activities, :force => true, :options => db_optionts do |t|
      t.column :comments, :text
      t.column :date, :date, :null => false
      t.column :minutes, :integer, :default => 0, :null => false
      t.column :project_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
      t.column :invoice_id, :integer
    end
    add_index :activities, :project_id
    add_index :activities, :user_id
    
    #Creates table invoices.
    create_table :invoices, :force => true, :options => db_optionts do |t|
      t.column :name, :string, :null => false
      t.column :notes, :text
      t.column :client_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
      t.column :created_at, :datetime
      t.column :is_issued, :boolean, :default => false, :null => false
      t.column :issued_at, :datetime
    end
    add_index :invoices, :client_id
    add_index :invoices, :user_id
    add_index :invoices, :name, :unique => true
    
  end

  def self.down
    drop_table :roles
    drop_table :users
    drop_table :clients
    drop_table :projects
    drop_table :invoices
    drop_table :activities
  end
end
