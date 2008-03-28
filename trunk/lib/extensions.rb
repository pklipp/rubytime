module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module SchemaStatements
      def set_database_charset(charset="utf8",collation="utf8_general_ci")
        if ActiveRecord::Base.configurations[RAILS_ENV]['adapter']=="mysql"
          execute "ALTER DATABASE DEFAULT CHARACTER SET #{charset} DEFAULT COLLATE #{collation}"
        end
      end
    end
  end
end


class String
  # Generated random alphanumeric string. Lenght is given as param - deafult is 16.
  def self.random(size=16)
    s = ""
    size.times { s << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
    s
  end
end

class TrueClass
  def to_english
    "YES"
  end
end

class FalseClass
  def to_english
    "NO"
  end
end

class NilClass
  def to_english
    "NO"
  end
end
