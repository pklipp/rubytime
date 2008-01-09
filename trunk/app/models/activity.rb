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

class Activity < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  belongs_to :role
  belongs_to :invoice
  
  # validators
  validates_presence_of :comments,  :project_id, :user_id, :date
  validates_numericality_of :minutes
  validates_presence_of :minutes
  validates_inclusion_of :minutes, :in => 1..1000, :message => "are out of range"

  # duration of activity is given in 2 formats:
  # - hr:min
  # - hr (can be also float e.x. "1.5")
  # This method converts both of them to minutes
  def Activity.convert_duration(minutes_str)
    return nil unless minutes_str.delete("0-9:.").blank?
    if (minutes_str.index(':'))
      h, m = minutes_str.split(/:/)
      minutes = (h.to_i * 60) + m.to_i
    else
      minutes = minutes_str.to_f * 60
    end
    minutes
  end

  #
  # Gets list of activities meeting specified conditions
  # If pagination_options are specified uses paginating find plugin.
  #
  # ==== Options
  # Options acts as filters for set of results
  # +role_id+:: Select activities with specified role
  # +user_id+:: Select activities from specified user
  # +project_id+:: Select activities from specified project
  # +date_from+:: Filter activities by starting date, date format is String (01-12-2007)
  # +date_to+:: Filter activities by end date, date format is String (01-12-2007)
  # +is_invoiced+:: Select already invoiced activities
  # +default_year+:: If date_from and date_to is not selected, use this year
  # +default_month+:: If date_from and date_to is not selected, use this month
  #
  # ==== Pagination options
  # +per_page+:: How many results per page should be returned
  # +current+:: Current page number
  #
  def self.list( options={}, pagination_options={} )
    cond_str, cond_arr = [ " 1 ", [] ];
    options||= {}
        
    unless options[:role_id].blank?
      cond_str+= " AND ((SELECT role_id FROM users WHERE users.id=user_id)=?)"
      cond_arr<< options[:role_id]
    end

    unless options[:user_id].blank?
      cond_str+= " AND user_id=?"
      cond_arr<< options[:user_id]
    end
    
    unless options[:project_id].blank?
      cond_str+= " AND project_id=?"
      cond_arr<< options[:project_id]
    end

    unless options[:date_from].blank?
      cond_str+= " AND date >= ?"
      cond_arr<< options[:date_from]
    end
      
    unless options[:date_to].blank?
      cond_str+= " AND date <= ?"
      cond_arr<< options[:date_to]
    end

    if options[:is_invoiced].to_i > 0
      if options[:is_invoiced].to_i == 1
        cond_str+= " AND invoice_id IS  NULL "
      elsif options[:is_invoiced].to_i == 2
        cond_str+= " AND invoice_id IS NOT NULL "
      end        
    end 

    # TODO
    if ( options[:date_from].blank? and options[:date_to].blank? )
      unless options[:default_year].blank?
        cond_str+= " AND #{SqlFunction.get_year('date')}='" + options[:default_year] + "'"
      end
      unless options[:default_month].blank?
        cond_str+= " AND #{SqlFunction.get_month_equation('date', options[:default_month])} "
      end  
    end
     
    # Use paginating find if :pagination_options are specified
    unless pagination_options.empty?
      pagination_options[:per_page]||= 30
      pagination_options[:current]||= 0

      activities = self.find(:all, :conditions=> [cond_str]+ cond_arr, :page=>{ :current=> pagination_options[:page].to_i, :size=> pagination_options[:per_page] }, :order=> "date DESC")

      pages = ActionController::Pagination::Paginator.new nil, activities.size, 
              pagination_options[:per_page], pagination_options[:current]
              
      return [pages, activities.load_page]
    else
      return self.find(:all, :conditions=> [cond_str]+ cond_arr, :order=> "date DESC")
    end
  end

end
