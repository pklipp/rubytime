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
  
  #
  # Signs-in user if login and password are correct, by setting session[:user_id]
  # This is a default way to authorize users in application
  #
  def login
    # If it's GET request, render form
    if request.get?
      session[:user_id] = nil
      @log_user = User.new
    
    # Try logging in if POST request
    elsif request.post?
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

  #
  # Logs out current user by setting session[:user_id] to nil
  # 
  def logout
    session[:user_id] = nil
    redirect_to(:action => "login")
  end
  
  #
  # Shows credits page
  #
  def credits
    render :template => "layouts/credits"
  end
  
  def remember_password
    user = User.find_by_email('krzysztof.knapik@llp.pl')
    a = Notifier.deliver_remember_password(user)
    render :text => "Mail was sent. \n" + a.to_s
  end
  
end
