class AdminController < ApplicationController
  before_filter :authorize              # force authorisation 
  layout "main", :except => :graph_xml  # graph_xml is loaded only by AJAX, no layout needed
  
  # Default action
  def index
  end
  
  #Dumps database
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
  
  #Dumps table
  def dump_table(objects,name,columns_names)
    content = Array.new
    @query = String.new
    @query = "INSERT INTO " + name + " VALUES\n" 
    counter = 0
    for object in objects
      counter += 1
      @query += "("
      content.clear
      for column in columns_names
        unless object.send(column.name).nil?
          if column.number?
            content<< object.send(column.name).to_s
          else
            content<< "'" + object.send(column.name).to_s.gsub(/'/,"\\\\'").gsub(/"/,'\\\\"').gsub(/\n/,"\\\\n").gsub(/\r/,"\\\\r") + "'"
          end
        else
          content<< "NULL"
        end
      end
      @query += content * ","
      counter==objects.length ? @query += ");\n" : @query += "),\n"
    end
    return @query
  end
  
end
