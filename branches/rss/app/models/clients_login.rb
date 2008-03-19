# ************************************************************************
# Ruby Time
# Copyright (c) 2006 Lunar Logic Polska sp. z o.o.
# 
# Permission is hereby granted, free of charge, to any person obtaining a 
# copy of this software and associated documentation files (the 
# "Software"), to deal in the Software without restriction, including 
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to 
# permit persons to whom the Software is furnished to do so, subject to 
# the following conditions:
# 
# The above copyright notice and this permission notice shall be included 
# in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# ************************************************************************

class ClientsLogin < ActiveRecord::Base
  attr_accessor :new_password, :force_checking_password
  belongs_to :client
  
  validates_presence_of :login, :client_id
  validates_uniqueness_of :login
  validates_presence_of :new_password, :if => Proc.new{|u| u.force_checking_password==true}
  validates_length_of :new_password, :minimum => 5, :allow_blank=> true
  validates_confirmation_of :new_password
  
  after_validation :encrypt_password
  before_save :encrypt_password
    
  # Tries to authorize client basing on login and password information
  # On success returns object of +Client+ class, on failure returns +nil+ 
  def self.authorize(login, password)
    login_details = self.find_by_login_and_password( login, Digest::SHA1.hexdigest(password))
    login_details ? login_details.client : nil 
  end
  
#  def password
#    return "" if @password.nil? and attributes['password'].nil?
#    @password
#  end
#

  def encrypt_password
    return if new_password.blank?
    self.password = Digest::SHA1.hexdigest(new_password)
    self.new_password = nil
    self.new_password_confirmation = nil
  end
  
  def password_equals? var
    password == Digest::SHA1.hexdigest(var)
  end
  
  
end
