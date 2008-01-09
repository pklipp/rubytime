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
#    helper :all
  #
  # Checks if the user has permissions to view requested page.
  # If no, shows "no_permission" partial.
  #
  def authorize
    @current_user = nil
    
    # Check if user is not logged in - redirect him to login page.
    unless session[:user_id]
      flash[:notice] = "Please log in"
      redirect_to(:controller => "login", :action => "login") and return false
    end
    
    # User is logged in, restore record
    @current_user=User.find(session[:user_id]);
    
    # Check if user is inactive - redirect him to 'inactive' page
    if @current_user.is_inactive
      render :partial => "users/inactive", :layout => "main" and return false
    end
    
    # Check user permissions
    unless @current_user.has_permissions_to?(params[:controller], params[:action])
      # user is not allowed to view the page. Show proper info
      render :inline => "<div id=\"errorNotice\">You have no permisions to view this page!</div>", :layout => "main" and return false
    end
  end

  #
  # Checks if the client-user has permissions to view requested page.
  # If no, shows "no_permission" partial.
  #
  def authorize_client   
    @current_client = nil

    # if client is not logged in - redirect him to login page.
    unless session[:client_id]
      flash[:notice] = "Please log in"
      redirect_to(:controller => "clientsportal", :action => "login") and return false
    end
    
    # Client is logged in, restore record
    @current_client=Client.find(session[:client_id]);
    
    # Check if client is inactive - redirect to 'inactive' page
    if @current_client.is_inactive
      render :partial => "users/inactive", :layout => "clientportal" and return false        
    end
  end
  
  #
  # Sets calendar options choosen by user and saves them into the session
  # 
  def set_calendar 
    session[:year]=params[:year] if params[:year]
    session[:month]=params[:month] if params[:month] 
    redirect_to request.env['HTTP_REFERER'] and return
  end
  
  #
  # Sets calendar options tu nils
  #
  def unset_calendar 
    session[:year]=nil
    session[:month]=nil  
    redirect_to request.env['HTTP_REFERER'] and return
  end
  
end