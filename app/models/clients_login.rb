class ClientsLogin < ActiveRecord::Base
  
  belongs_to :client
  
  validates_presence_of :login, :password, :client_id
  validates_uniqueness_of :login
  validates_length_of :password, :minimum => 5
  validates_confirmation_of :password  
    
  # Tries to authorize client basing on login and password information
  # On success returns object of +Client+ class, on failure returns +nil+ 
  def self.authorize(login, password)
    login_details = self.find_by_login_and_password( login, Digest::SHA1.hexdigest(password))
    login_details ? login_details.client : nil 
  end
  
end
