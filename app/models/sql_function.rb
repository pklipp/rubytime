class SqlFunction < ActiveRecord::Base

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
