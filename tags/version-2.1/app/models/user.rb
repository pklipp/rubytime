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
  require 'digest/sha1' # needed for password hashing
  
  has_many :activities, :dependent => :destroy
  has_many :projects, :through => :activities, :group => "project_id"
#  has_one :rss_feed, :as => :owner, :dependent => :destroy

  belongs_to :role

  validates_presence_of :login, 
                        :name,  
                        :email, 
                        :role_id 
  validates_length_of :password, 
                      :minimum => 5,
                      :message => "should be at least 5 characters long",
                      :allow_nil=> true
  validates_uniqueness_of :login, :email
  validates_confirmation_of :password  
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i 

  attr_protected :id, :salt
  attr_accessor :password

  #
  # Initializes new object by creating new salt for storing encrypted passwords
  #
  def initialize( *args )
    super( *args )
    self.salt = self.class.create_new_salt
  end

  #
  # Searches for users by login or name
  # Active users are returned first
  #
  def self.search( text )
    self.find(:all, :conditions => ["login LIKE ? OR name LIKE ?", "%#{text}%", "%#{text}%"], :order => "is_inactive")
  end

  #
  # Checks if user has administrator privileges
  #
  def is_admin?
    self.role.is_admin?
  end

  #
  # Tries to authorize user basing on login and password information
  # On success returns object of +User+ class, on failure returns +nil+
  # 
  def self.authorize(login, password)
    unless ( user = User.find_by_login(login) ).nil?
      return user if User.hashed_pass( password, user.salt ) == user.password_hash
    end

    nil
  end  
    
  #
  # Checks if the user has permissions to view specified controller and action 
  # If user has administrator role, he has all permissions
  #
  def has_permissions_to?(controller, action)
    return true if self.is_admin?
    
    case controller # those controllers are not allowed by default
      when "your_data", "login", "sparklines"
        true
      else
        false
    end
  end
  
  #
  # Updates user's password
  #
  def password= v
    @password = v
    self.password_hash = self.class.hashed_pass( v, self.salt )
  end

  #
  # Checks if user password is the same as one passed as arg
  #
  def password_equals? p 
    self.password_hash == self.class.hashed_pass( p.to_s, self.salt )
  end
  
  #
  # Returns hashed version of password from given password and salt
  #
  # This function uses +SHA1+ digest algorithm combined with 
  # password salt for additional protection.
  #
  def self.hashed_pass(pass,salt)
    string_to_hash = pass.to_s + "wibble" + salt.to_s
    Digest::SHA1.hexdigest(string_to_hash)
  end
  
  #
  # Generates new, random salt and returns it as string
  #
  def self.create_new_salt
    self.object_id.to_s + rand.to_s
  end
  
  #
  # Finds all +active+ users sorted in +alphabetic order+
  #
  def User.find_active
    User.find_all_by_is_inactive(false, :order => "name")
  end

end
