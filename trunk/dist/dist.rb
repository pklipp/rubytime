# RubyTime distribution maker
#
# author: Wiktor Gworek

require 'net/http'
require "rubygems"
require 'fileutils'
gem "sqlite3-ruby"

environment_config = <<END
module Rails
  class Configuration
    def database_configuration
      conf = YAML::load(ERB.new(IO.read(database_configuration_file)).result)
      if defined?(TAR2RUBYSCRIPT)
        conf.each do |k, v|
          if v["adapter"] =~ /^sqlite/
            v["database"] = oldlocation(v["database"]) if v.include?("database")
            v["dbfile"]   = oldlocation(v["dbfile"])   if v.include?("dbfile")
          end
        end
      end
      conf
    end
  end
end
END

database_yml = <<END
development:
  adapter: sqlite3
  database: rubytime_development.db

test:
  adapter: sqlite3
  database: rubytime_test.db

production:
  adapter: sqlite3
  database: rubytime_production.db
END

init_rb = <<END
at_exit do
  require "irb"
  require "drb/acl"
  require "sqlite3"
end

ENV['RAILS_ENV'] = 'production'
load "script/server"
END

def append_to_file_top(file_name, content)
  file_content = File.open(file_name, 'r').readlines
  File.open(file_name, 'w') do |file|
    file << content
    for line in file_content
      file << line
    end
  end
end

def create_file(file_name, content)
  File.open(file_name, 'w') do |file|
    file << content
  end
end

def download_file(host, path, file_name)
  Net::HTTP.start(host) do |http|
    resp = http.get(path)
    open(file_name, "wb") do |file|
      file.write(resp.body)
    end
  end
end

def task(msg)
  print " -> #{msg}"
  $stdout.flush
  yield
  puts "\t [ OK ]"
end

# URLs
svn_repo = "http://rubytime.googlecode.com/svn/trunk/"

# Checking out code from repository
task "Checking out code from repository" do
  `svn export #{svn_repo} rubytime`
end

# Removing web-packages dir
task "Cleaning up" do
  FileUtils.remove_dir "rubytime/web-packages"
  FileUtils.remove_dir "rubytime/dist"
end

#task_start "Downloading scripts: Tar2RubyScript & RubyScript2Exe"
#download_file("www.erikveen.dds.nl", "/tar2rubyscript/download/tar2rubyscript.rb", "tar2rubyscript.rb")
#download_file("www.erikveen.dds.nl", "/rubyscript2exe/download/rubyscript2exe.rb", "rubyscript2exe.rb")
#task_end

create_file 'rubytime/config/database.yml', database_yml
create_file 'rubytime/init.rb', init_rb
append_to_file_top 'rubytime/config/environment.rb', environment_config

task "Creating empty database" do
  `cd rubytime && rake db:migrate RAILS_ENV=production`
  FileUtils.move("rubytime/rubytime_production.db", ".")
  FileUtils.remove_file("rubytime/log/production.log")
end

task "Creating RBA distro\n" do
  `ruby tar2rubyscript.rb rubytime/`
end

#task "Creating executable standalone for Windows\n" do
#  `ruby rubyscript2exe.rb rubytime.rb`
#end
