# ************************************************************************
# Ruby Time
# Copyright (c) 2006 Lunar Logic Polska sp. z o.o.
# 
# This code is licensed under the MIT license.
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

class User < ActiveRecord::Base
  require 'digest/sha1' # needed to password hashing
  
  has_many :activities
  has_many :projects, :through => :activities, :group => "project_id"
  
  belongs_to :role

  validates_presence_of :login, 
                        :name, 
                        :password, 
                        :email, 
                        :role_id 
  validates_length_of :password, 
                      :minimum => 5,
                      :message => "should be at least 5 characters long"                       
  validates_uniqueness_of :login
  validates_confirmation_of :password  
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i 


  #Changes administratof privileges
  def is_admin
    if self.role.is_admin
      return true
    else
      return false
    end
  end

  # Logs user.
  def self.login(login, password)
    tmp = find(:first,:conditions =>  ["login = ? ", login])     
    if !tmp.nil?
      tmp_password = User.hashed_pass(password, tmp.salt)
      find(:first,
           :conditions => ["login = ? and password = ?", login, tmp_password])
    else
      nil
    end
  end  
  
  # Logs user by "login" method
  def try_to_login
    User.login(self.login, self.password)
  end  

  
  # Checks if the user has permissions to view controller 
  # and action given in parameters
  def has_permisions_to(controller, action)
    case self.role.is_admin 
      when true
        true 
      else
        case controller # those controllers are not allowed by default
          when "users", "roles", "activities", "clients", "projects", "invoices"
            false
          else
            true
        end
    end
  end
  
  # Hashes password from given password and salt.
  def self.hashed_pass(pass,salt)
    string_to_hash = pass + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
  
  # Creates new salt usind to password hashing
  def self.create_new_salt
    self.object_id.to_s + rand.to_s
  end
  
end
