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

  protect_from_forgery :secret => '33552ece661a5a356fade27bb90fa02f'

  private

  #
  # Checks if +normal user+ is logged in, is active, and has permissions to access requested controller/action
  # This method is present in most before_filters, to authorize users
  # This method sets up +@current_user+
  # If user is not authorized, shows "no_permission" partial.
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
      render :partial => "/users/no_permissions", :layout => "main" and return false
    end
  end

  #
  # Checks if the +client user+ is logged in and is active
  # This method is present in before_filters in client section to authorize client
  # This method sets up @current_client
  # If client is not authorized, shows "no_permission" partial.
  #
  def authorize_client   
    @current_client = nil

    # If client is not logged in - redirect him to login page.
    unless session[:client_id]
      flash[:notice] = "Please log in"
      redirect_to(:controller => "clientsportal", :action => "login") and return false
    end
    
    # Client is logged in, restore record
    @current_client=Client.find(session[:client_id]);
    
    # Check if client is inactive - redirect to 'inactive' page
    if @current_client.is_inactive?
      render :partial => "users/inactive", :layout => "clientportal" and return false        
    end
  end

  def render_rss_feed(activities)
    @days = activities.group_by {|act| act.created_at.to_date}
    @pub_dates = {}

    @days.each do |day, day_activities|
      projects = day_activities.group_by {|act| act.project}
      projects.each do |project, project_activities|
        roles = project_activities.group_by {|act| act.user.role}
        roles.each do |role, role_activities|
          users = role_activities.group_by {|act| act.user}
          roles[role] = users
        end
        projects[project] = roles
      end
      @pub_dates[day] = day_activities.collect(&:created_at).max
      @days[day] = projects
    end

    respond_to do |format|
      format.html {render :template => 'your_data/rss'}
      format.rss {render :template => 'your_data/rss', :layout => false}
    end
  end

  def prepare_graph_xml(options = {})
    params[:search] = session[:graph]
    session[:graph] = nil

    prepare_search_dates
    query_results = Activity.for_graph(params[:search].merge(options))
    @activities, @grouped_roles, @weeks, @years = query_results.values_at(:activities, :grouped_roles, :weeks, :years)
  end

  # generalized authorize_*_to_feed for both client (clientsportal) and project manager (your_data)
  # required 3 options, each is a block:
  # :current_user => returns @current_user or @current_client
  # :authorize => authorize() / authorize_client()
  # :http_check => function(login, pass) {is login/pass the login/pass of the feed owner?}
  def authorize_to_feed(options = {})
    raise ArgumentError if options[:current_user].nil? or options[:authorize].nil? or options[:http_check].nil?

    assert_params_must_have :id

    begin
      @feed = RssFeed.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render :text => "Feed id not found" and return false
    end

    if request.format == 'text/html'
      return false unless options[:authorize].call
      if @feed.owner != options[:current_user]
        render :text => "Access to feed denied" and return false
      end
    end

    case @feed.authentication
      when 'key'
        if params[:key] != @feed.secret_key
          render :text => "Access to feed denied" and return false
        else
          return true
        end
      when 'http'
        authenticate_or_request_with_http_basic(&options[:http_check])
      else
        false
    end
  end

  public

  #
  # Sets calendar options choosen by user and saves them into the session
  #
  def set_calendar 
    session[:year] = params[:year] if params[:year]
    session[:month] = params[:month] if params[:month]
    redirect_to request.env['HTTP_REFERER'] and return
  end

  #
  # Sets calendar options stored in session to nils
  #
  def unset_calendar 
    session[:year] = nil
    session[:month] = nil
    redirect_to request.env['HTTP_REFERER'] and return
  end
end