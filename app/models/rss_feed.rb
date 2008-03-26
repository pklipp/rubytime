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

require 'digest/sha1'

class RssFeed < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true

  has_many :elements, :class_name => 'RssFeedElement', :dependent => :destroy do
    def projects
      @projects ||= find_all {|el| el.project != nil && el.role.nil? && el.user.nil?}.collect(&:project_id)
    end

    def roles
      @roles ||= find_all {|el| el.project.nil? && el.role != nil && el.user.nil?}.collect(&:role_id)
    end

    def users
      @users ||= find_all {|el| el.project.nil? && el.role.nil? && el.user != nil}.collect(&:user_id)
    end

    def roles_in_project(project)
      @roles_in_project ||= {}
      @roles_in_project[project] ||= find_all {|el| el.project == project && el.role != nil && el.user.nil?}.collect(&:role_id)
    end

    def users_in_project(project)
      @users_in_project ||= {}
      @users_in_project[project] ||= find_all {|el| el.project == project && el.role.nil? && el.user != nil}.collect(&:user_id)
    end
  end

  def generate_random_key
    self.secret_key = Digest::SHA1.hexdigest("#{rand}-#{Time.now.tv_usec}-#{self.owner.name}")
  end
end
