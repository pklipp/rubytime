class CreateDefaultUser < ActiveRecord::Migration
  def self.up
    User.create(:login => 'admin', :name => 'admin', :email => 'admin@test.site.com', :role_id => 1, :password_hash => '7be43c1935a3d4ccd904a062a0e8925fb986829f', :salt => '287560120.570862222928554', :is_inactive => false) if User.count == 0
  end

  def self.down
    u = User.find_by_login_and_name_and_email_and_salt('admin', 'admin', 'admin@test.site.com', '287560120.570862222928554')
    u.destroy if u
  end
end
