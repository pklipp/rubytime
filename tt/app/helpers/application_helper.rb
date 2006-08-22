# ************************************************************************
# Time Tracker
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


module ApplicationHelper
  
  # Shows calendar with selected session month nad year 
  def calendar

    yearClass={2006 => "", 2007 => "", 2008 => ""}
    yearClass[2006]=""
    yearClass[2007]=""
    yearClass[2008]=""
    yearClass[session[:year].to_i]="selected"
    monthClass={"","","","","","","","","","","",""}
    monthClass[session[:month].to_i]="selected"
  
    result_string = %Q!
    <table class="calendar">
      <tr>
      	<td>
      		Year: 
      	</td>
      	<td colspan="4" class="#{yearClass[2006]}">
      	  #{link_to '2006', {:action => 'set_calendar', :year => "2006"} }
      	</td>
      	<td colspan="4" class="#{yearClass[2007]}">
      	  #{link_to '2007', {:action => 'set_calendar', :year => "2007"} }
      	</td>
      	<td colspan="4" class="#{yearClass[2008]}">
      	  #{link_to '2008', {:action => 'set_calendar', :year => "2008"} }
      	</td>
      </tr>
      <tr>
       	<td>
      		Month: 
      	</td>
      	<td class="#{monthClass[1]}">
      	 #{link_to 'Jan', {:action => 'set_calendar', :month => "1"} }
      	</td>
      	<td class="#{monthClass[2]}">
      	 #{link_to 'Feb', {:action => 'set_calendar', :month => "2"} }
      	</td>
      	<td class="#{monthClass[3]}">
      	 #{link_to 'Mar', {:action => 'set_calendar', :month => "3"} }
      	</td>
      	<td class="#{monthClass[4]}">
      	 #{link_to 'Apr', {:action => 'set_calendar', :month => "4"} }
      	</td>
      	<td class="#{monthClass[5]}">
      	 #{link_to 'May', {:action => 'set_calendar', :month => "5"} }
      	</td>
      	<td class="#{monthClass[6]}">
      	 #{link_to 'Jun', {:action => 'set_calendar', :month => "6"} }
      	</td>
      	<td class="#{monthClass[7]}">
      	 #{link_to 'Jul', {:action => 'set_calendar', :month => "7"} }
      	</td>
      	<td class="#{monthClass[8]}">
      	 #{link_to 'Aug', {:action => 'set_calendar', :month => "8"} }
      	</td>
      	<td class="#{monthClass[9]}">
      	 #{link_to 'Sep', {:action => 'set_calendar', :month => "9"} }
      	</td>
      	<td class="#{monthClass[10]}">
      	 #{link_to 'Oct', {:action => 'set_calendar', :month => "10"} }
      	</td>
      	<td class="#{monthClass[11]}">
      	 #{link_to 'Now', {:action => 'set_calendar', :month => "11"} }
      	</td>
      	<td class="#{monthClass[12]}">
      	 #{link_to 'Dec', {:action => 'set_calendar', :month => "12"} }
      	</td>
      </tr>
      <tr>
        <td style="colspan: 12; padding-top: 5px">
          #{link_to 'Unselect', {:action => 'unset_calendar'} } 
        </td>
      </tr>    
    </table>
   	!
  end  
  
  # Changes minutes as an integer to hour format hh:mm
  def hour_format(minutes)
    array=minutes.divmod(60);
    return_string = array[0].to_s + ":" + (100+array[1]).to_s.slice(1,2);
  end
  
end
