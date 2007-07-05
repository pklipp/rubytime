# RubyTime distribution maker
require 'net/http'
require "rubygems"
require 'fileutils'
gem "sqlite3-ruby"

environment_config = 'module Rails
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
'

database_yml = 'development:
  adapter: sqlite3
  database: rubytime_development.db

test:
  adapter: sqlite3
  database: rubytime_test.db

production:
  adapter: sqlite3
  database: rubytime_production.db'
  
  init_rb = 'at_exit do
  require "irb"
  require "drb/acl"
  require "sqlite3"
end

load "script/server"'

def append_to_file_top(file_name, content) 
  file_content = File.open(file_name, 'r').readlines
  File.open(file_name, 'w') { |file|
      file << content 
      for line in file_content
        file << line
      end
  }
end

def create_file(file_name, content)
  File.open(file_name, 'w') do |file|
    file << content
  end
end


def download_file(host, path, file_name) 
	Net::HTTP.start(host) { |http|
	  resp = http.get(path)
	  open(file_name, "wb") { |file|
		file.write(resp.body)
	   }
	}
end

def task_start(msg)
	print " -> #{msg}"
end

def task_end
	print "\t [ OK ]\n"
end

# URLs
svn_repo = "http://rubytime.googlecode.com/svn/trunk/"

# Checking out code from repository
task_start "Checking out code from repository"
`svn checkout #{svn_repo} rubytime`
task_end

# Removing web-packages dir
task_start "Removing rubytime/web-packages dir"
FileUtils.remove_dir "rubytime/web-packages"
task_end

task_start "Downloading scripts: Tar2RubyScript & RubyScript2Exe"
download_file("www.erikveen.dds.nl", "/tar2rubyscript/download/tar2rubyscript.rb", "tar2rubyscript.rb")
download_file("www.erikveen.dds.nl", "/rubyscript2exe/download/rubyscript2exe.rb", "rubyscript2exe.rb")
task_end

create_file 'rubytime/config/database.yml', database_yml
create_file 'rubytime/init.rb', init_rb
append_to_file_top 'rubytime/config/environment.rb', environment_config

task_start "Creating RBA distro\n"
`ruby tar2rubyscript.rb rubytime/`
task_end

task_start "Creating executable standalone for Windows\n"
`ruby rubyscript2exe.rb rubytime.rb`
task_end

