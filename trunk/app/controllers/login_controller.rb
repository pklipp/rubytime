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
        if logged_in_user.is_inactive?
          flash[:error] = "Your account is currently inactive"
        else
          session[:user_id] = logged_in_user.id
          redirect_to(:controller => "your_data")
        end
      else
        session[:user_id] = nil
        flash[:error] = "Invalid user/password combination"
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


  def change_password
    @pass_change_user = User.find(:first, :conditions => ["password_code = ?", params[:code]])
    redirect_to :action => :login unless @pass_change_user
    if request.post?
      if params[:user][:password] != params[:user][:password2] 
        flash[:notice]="Passwords do not match"
        redirect_to :action => :change_password, :code => params[:code]
      elsif params[:user][:password].length < 5
        flash[:notice]="Password must be at least 5 chars long"
        redirect_to :action => :change_password, :code => params[:code]
      elsif
        #save new password
        @pass_change_user = User.find(:first, :conditions => ["password_code = ?", params[:code]])
        @pass_change_user.salt = User.create_new_salt
        @pass_change_user.password = params[:user][:password]
        @pass_change_user.save!
        #clear and redirect
        flash[:notice] = "Password changed"
        redirect_to :action => :login
      end
    end
  end

  def forgot_password
    if params[:forgot_pass][:email].nil?
      flash[:notice] = "E-mail box can't be blank" 
      redirect_to :action => :login
    elsif user = User.find(:first, :conditions => ["email = ? ", params[:forgot_pass][:email]])
      user.password_code = String.random
      #Save code
      user.save
      #send email with link
      Notifier.deliver_forgot_password(user)
      #redirect
      flash[:notice]="Check your mail" 
      redirect_to :action => :login
    else
      flash[:notice]="No such mail in database"
      redirect_to :action => :login   
    end
  end
  
end
