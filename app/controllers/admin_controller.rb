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

class AdminController < ApplicationController
  before_filter :authorize              # force authorisation 
  layout "main"
  
  #
  # Default empty action
  #
  def index
    render_text ""
  end

  #
  # Shows all activities from previous day
  # Usefull in situations when admin needs to see what have been done since yesterday
  # 
  def previous_day
    yesterday = (Time.now - 1.day).strftime("%Y-%m-%d")
    @activities = Activity.find(:all, :conditions => ["date = ? ", yesterday])
  end
  
  #
  # Dumps database using mysqldump and sends dump file to browser
  # The dump is created in memory
  #
  def dump
    dump = StringIO.new
    filename = "dump-" + Date.today.to_s + ".sql"
    database = ActiveRecord::Base.configurations[RAILS_ENV]['database']
    username = ActiveRecord::Base.configurations[RAILS_ENV]['username']
    password = ActiveRecord::Base.configurations[RAILS_ENV]['password']
    if password.nil?
      dump.write(`mysqldump -u #{username} #{database}`)
    else
      dump.write(`mysqldump -u #{username} -p#{password} #{database}`)
    end
    dump.rewind    
    send_data(dump.read,
      :type => 'text/plain; charset=utf-8; header=present',
      :filename => filename)
  end
  
  #
  # Dumps database to YAML format and sends it to browser
  # The dump is created in memory
  #
  def export_db
    filename = "dump_" + Time.now.strftime('%Y-%m-%d-%H-%M') + ".txt"
    dump = {}
    dump['activties'] = Activity.find(:all)
    dump['clients'] = Client.find(:all)
    dump['invoices'] = Invoice.find(:all)
    dump['projects'] = Project.find(:all)
    dump['roles'] = Role.find(:all)
    dump['users'] = User.find(:all)
    dumped_data = dump.to_yaml
    dumped_data.gsub(/\n/,"\r\n")
    send_data(dumped_data,
      :type => 'text/plain; charset=utf-8; header=present',
      :filename => filename)
  end
    
end
