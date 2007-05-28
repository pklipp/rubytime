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

class LoginController < ApplicationController
  layout "main"
  
  # Sign-in user if login and password are correct. Sets session[:user_id] to proper ID from database.
  def login
    if request.get?
      session[:user_id] = nil
      @log_user = User.new
    else
      logged_in_user = User.authorize(params[:log_user][:login], params[:log_user][:password])      
      if logged_in_user.kind_of? User
        session[:user_id] = logged_in_user.id
        redirect_to(:controller => "your_data")
      else
        session[:user_id] = nil
        flash[:notice] = "Invalid user/password combination"
      end
    end
  end

  # Logs user from key.
  def login_from_key
    if (params[:key])
      @user_tmp=User.find(:first, :conditions => [ "login_key LIKE ? ", params[:key]])
      if (@user_tmp)
        session[:user_id]=@user_tmp.id
        redirect_to(:controller => "users", :action => 'list' )
        @key="sss: " + session[:user_id].to_s + session[:user_id].to_s;
      end
    else
      @key="none";
    end
  end

  # Logs out user. 
  def logout
    session[:user_id] = nil
    redirect_to(:action => "login")
  end
  
end
