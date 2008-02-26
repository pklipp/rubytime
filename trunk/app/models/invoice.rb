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

class Invoice < ActiveRecord::Base
  belongs_to :client
  belongs_to :user
  has_many :activities
  has_many :projects, :through => :activity
  
  validates_presence_of :client_id, :name, :user_id
  validates_uniqueness_of :name
  validates_length_of(:name, :within => 2..20)
  
private
  #
  # Gets sql conditions array for specified options
  #
  # ==== Options
  # Options acts as filters for set of results
  # +client_id+:: Select invoices for specified client only
  # +name+:: Select invoices with given string in name
  # +date_from+:: Filter by starting date, date format is String (01-12-2007)
  # +date_to+:: Filter by end date, date format is String (01-12-2007)
  # +is_issued+:: If set to 0 selects all invoices; 1- not issued only; 2- issued only
  #
  def self.filter_conditions( options={} )
    cond_str, cond_arr = [ " 1 ", [] ];
    options||= {}
        
    unless options[:client_id].blank?
      cond_str+= " AND client_id=?"
      cond_arr<< options[:client_id]
    end

    unless options[:name].blank?
      cond_str+= " AND name LIKE ?"
      cond_arr<< "%#{options[:name]}%"
    end
    
    unless options[:date_from].blank?
      cond_str+= " AND date >= ?"
      cond_arr<< options[:date_from]
    end
      
    unless options[:date_to].blank?
      cond_str+= " AND date <= ?"
      cond_arr<< options[:date_to]
    end

    if options[:is_issued].to_i > 0
      if options[:is_invoiced].to_i == 1
        cond_str+= " AND is_issued = 0 "
      elsif options[:is_invoiced].to_i == 2
        cond_str+= " AND is_issued = 1 "
      end        
    end 
 
    return [cond_str] + cond_arr
  end


public

  def self.search(conditions = {})
    conditions_string = '1'
    conditions_hash = {}

    case conditions[:is_issued].to_i
      when 1: conditions_string << ' AND is_issued = false'
      when 2: conditions_string << ' AND is_issued = true'
    end

    unless conditions[:name].blank?
      conditions_string << ' AND invoices.name LIKE :inv_name'
      conditions_hash[:inv_name] = "%" + conditions[:name] + "%"
    end

    unless conditions[:client_id].blank?
      conditions_string << ' AND invoices.client_id = :client_id'
      conditions_hash[:client_id] = conditions[:client_id]
    end

    unless conditions[:date_from].blank?
      conditions_string << ' AND date(invoices.created_at) >= :date_from'
      conditions_hash[:date_from] = conditions[:date_from]
    end

    unless conditions[:date_to].blank?
      conditions_string << ' AND date(invoices.created_at) <= :date_to'
      conditions_hash[:date_to] = conditions[:date_to]
    end

    self.find :all,
      :conditions => [conditions_string, conditions_hash],
      :include => :client,
      :order => "created_at DESC"
  end
  
end
