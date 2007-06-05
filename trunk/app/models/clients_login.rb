class ClientsLogin < ActiveRecord::Base
  
  belongs_to :client
  
  validates_presence_of :login, :password, :client_id
  validates_uniqueness_of :login
  validates_length_of :password, :minimum => 5
  validates_confirmation_of :password  
    
  # Logs client. Method returns Client object if client is logged successfuly or nil when not.
  def self.authorize(login, password)
    tmp = find(:first, :conditions =>  ["login = ? ", login])
    if !tmp.nil?
      tmp_password = Digest::SHA1.hexdigest(password)
      client_login = find(:first, :conditions => ["login = ? and password = ?", login, tmp_password])
      
      return client_login.nil? ? nil : client_login.client
    else
      nil
    end
  end
  
end
