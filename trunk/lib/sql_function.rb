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

module SqlFunction

   def self.get_week(param)
      if ActiveRecord::Base.configurations[RAILS_ENV]['adapter']=="mysql"
        return "WEEK(#{param})"
      elsif ActiveRecord::Base.configurations[RAILS_ENV]['adapter']=="sqlite" 
        return "strftime(\"%W\",#{param})"
      elsif ActiveRecord::Base.configurations[RAILS_ENV]['adapter']=="sqlite3" 
        return "strftime(\"%W\",#{param})"
      #Postgres not testet yet!
      elsif ActiveRecord::Base.configurations[RAILS_ENV]['adapter']=="postgres" 
        return "EXTRACT(WEEK FROM #{param})"
      else
        return param
      end
   end

   def self.get_month(param)
      if ActiveRecord::Base.configurations[RAILS_ENV]['adapter']=="mysql"
        return "MONTH(#{param})"
      elsif ActiveRecord::Base.configurations[RAILS_ENV]['adapter']=="sqlite" 
        return "strftime(\"%m\",#{param})"
      elsif ActiveRecord::Base.configurations[RAILS_ENV]['adapter']=="sqlite3" 
        return "strftime(\"%m\",#{param})"
      #Postgres not testet yet!
      elsif ActiveRecord::Base.configurations[RAILS_ENV]['adapter']=="postgres" 
        return "EXTRACT(MONTH FROM #{param})"
      else
        return param
      end
   end

   
   def self.get_year(param)
      if ActiveRecord::Base.configurations[RAILS_ENV]['adapter']=="mysql"
        return "YEAR(#{param})"
      elsif ActiveRecord::Base.configurations[RAILS_ENV]['adapter']=="sqlite" 
        return "strftime(\"%Y\",#{param})"
      elsif ActiveRecord::Base.configurations[RAILS_ENV]['adapter']=="sqlite3" 
        return "strftime(\"%Y\",#{param})"
      #Postgres not testet yet!
      elsif ActiveRecord::Base.configurations[RAILS_ENV]['adapter']=="postgres" 
        return "EXTRACT(YEAR FROM #{param})"
      else
        return param
      end
   end


   def self.get_month_equation(param, value)
      value = (value.to_i < 10 ? "0" : "" ) + value.to_s
      self.get_month(param) + " = '#{value}' "
   end

   
end
