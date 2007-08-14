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

end
