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

class ApplicationController < ActionController::Base
  
  # Checks if the user has permissions to view requested page. 
  # If no, shows "no_permission" partial.
  def authorize   
    @current_user = nil
    unless session[:user_id] # if user is not logged in - redirect him to login page.
      flash[:notice] = "Please log in"
      redirect_to(:controller => "login", :action => "login") and return false
    else
      @current_user=User.find(session[:user_id]);
      if @current_user.is_inactive # if user is not logged in - redirect him to login page.
        render :partial => "users/inactive", :layout => "main" and return false
      else
        # checking permisions 
        if @current_user.has_permisions_to(params[:controller], params[:action]) 
          # OK user can view the page
        else # user is not allowed to view the page. Show proper info
          render :inline => "<div id=\"errorNotice\">You have no permisions to view this page!</div>", :layout => "main" and return false
        end
      end
    end
  end 
  
  # Sets calendar options choosen by user and saves them into the session 
  def set_calendar 
    @session[:year]=params[:year] if params[:year]
    @session[:month]=params[:month] if params[:month] 
    redirect_to @request.env['HTTP_REFERER'] and return
  end
  
  # Sets calendar options tu nils
  def unset_calendar 
    @session[:year]=nil
    @session[:month]=nil  
    redirect_to @request.env['HTTP_REFERER'] and return
  end
  
end