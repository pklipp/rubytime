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

class Project < ActiveRecord::Base

  has_many :activities, :dependent => :destroy
  belongs_to :client
  has_many :users, :through => :activities
  
  validates_presence_of :name, :description, :client_id
  validates_uniqueness_of :name
  
  # Finds all active projects
  def self.find_active
    Project.find(:all, :conditions => {:is_inactive => false}, 
      :order => "name")
  end
  
  def self.search( options={} )
    cond_str = "1 "
    cond_arr = []
    
    unless options[:name].blank?
        cond_str += " AND (projects.name LIKE ?" 
        cond_str += " OR projects.description LIKE ? )"
        2.times { cond_arr << "%#{options[:name]}%" }
    end

    unless options[:client_id].blank?
      cond_str += " AND client_id =?"
      cond_arr << options[:client_id]
    end

    self.find( :all, :conditions=> [cond_str] + cond_arr, :order=> "is_inactive" )
  end

#   def self.report_by_role( project_id, from_date, to_date )
#       sql_str = "SELECT roles.name as role_name, sum(activities.minutes) as minutes " +
#       " FROM ((users left join activities on activities.user_id = users.id) LEFT JOIN projects on projects.id = activities.project_id) LEFT JOIN roles ON users.role_id = roles.id " +
#       " WHERE projects.id = ? AND " +
#       " activities.date <= ? AND " +        
#       " activities.date >= ? " + 
#       " GROUP BY roles.name"
#       sql_arr = [ project_id, to_date, from_date ]
# 
#       @reports = self.find_by_sql( [sql_query] + sql_arr )
#   end

  def create_report_by_role(from_date, to_date)
    conditions_string = 'projects.id = ?'
    conditions_array = [self.id]
    unless from_date.blank?
      conditions_string << ' AND activities.date >= ?'
      conditions_array << from_date
    end
    unless to_date.blank?
      conditions_string << ' AND activities.date <= ?'
      conditions_array << to_date
    end

    activities = Activity.find :all,
      :conditions => [conditions_string, *conditions_array],
      :include => [:user, :project],
      :order => "users.role_id",
      :joins => "left join roles on (users.role_id = roles.id)"

    reports = []
    unless activities.blank?
      minutes_sum = 0
      last_role = activities.first.user.role
      for act in activities
        if act.user.role != last_role
          reports << minutes_sum
          last_role = act.user.role
          minutes_sum = 0
        end
        reports << act
        minutes_sum += act.minutes
      end
      reports << minutes_sum
    end
    reports
  end

  # Returns String
  # * -YES- if project is active
  # * -NO- if project is not active
  def active_text
    is_inactive? ? "NO" : "YES"
  end

end
