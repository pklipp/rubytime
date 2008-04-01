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
class YourDataController < ApplicationController

  include ActionView::Helpers::JavaScriptHelper
  include ApplicationHelper

  helper :sparklines
  before_filter :authorize, :load_activity, :except => :rss
  before_filter :authorize_user_to_feed, :only => :rss
  layout "main", :except => :graph_xml

  # Activity filter provides reusable method prepare_search_dates
  require 'params_filter'
  include ParamsFilter

private
  #
  # Loads project if params[:id] is given. This method should be called in before_filter.
  #
  def load_activity
    @activity = Activity.find(params[:id]) if params[:id]
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "No such activity"
    redirect_to :action => :index
  end

  def authorize_user_to_feed
    authorize_to_feed :current_user => Proc.new {@current_user},
      :authorize => Proc.new {authorize},
      :http_check => Proc.new {|login, pass| user = User.authorize(login, pass) and !user.is_inactive? and @feed.owner == user}
  end

  def update_calendar_user_id
    session[:calendar_user_id] = params[:user_id].to_i if params[:user_id]
    session[:calendar_user_id] = @current_user.id unless @current_user.is_admin?
    session[:calendar_user_id] ||= @current_user.id
    @calendar_user_id = session[:calendar_user_id]
    @calendar_user = User.find(@calendar_user_id)
  end

public
  #
  # Default action. Shows activities calendar.
  #
  def index
      activities_calendar
      render :action => 'activities_calendar'
  end

  #
  # Redirects to list of activitities or graph depending on submit button
  # with data specified by search conditions
  #
  def search
    if params[:commit] == "Generate graph"
      graph
      render :action => 'graph'
    else
      activities_list
      render :action => 'activities_list'
    end
  end

  #
  # Shows list of current user's activities, all or filtered by search conditions
  #
  def activities_list
    update_calendar_user_id
    if params[:search].nil? and session[:month].nil? and session[:year].nil?
      @activities = Activity.list({:user_id => @calendar_user_id}, {:page => params[:page], :per_page => 10})
    else
      prepare_search_dates
      params[:search][:user_id] = @calendar_user_id
      @activities = Activity.list(params[:search])
    end
  end

  #
  # Shows activities grid for choosen year & month (like calendar)
  #
  def activities_calendar
    update_calendar_user_id
    session[:year] ||= Time.now.year.to_s
    session[:month] ||= Time.now.month.to_s
    @activities = Activity.list :default_month => session[:month], :default_year => session[:year], :user_id => @calendar_user_id
  end

  #
  # Shows chosen activity details
  #
  def show_activity
    assert_params_must_have :id
    render :partial => "/users/no_permissions", :layout => "main" and return false unless @activity.viewable_by? @current_user
  end

  #
  # Shows form for new activity.
  #
  def new_activity
    @activity = Activity.new

    # use date from params[:date] if the action is called from the calendar
    @activity.date = params[:date].nil? ? Date.today : Date.parse(params[:date])

    @projects = Project.find_active
    @activity.project_id = @current_user.activities.find_recent.project_id unless @current_user.activities.empty?
  end

  #
  # Creates new activity based on information passed in form
  #
  def create_activity
    # Convert duration of activity to unified format
    params[:activity]['minutes'] = Activity.convert_duration(params[:activity]['minutes'])

    @activity = Activity.new(params[:activity])
    @activity.user = @current_user
    @projects = Project.find_active

    # Warn user if he already has activity on the same project/date pair
    if @current_user.activities.find_by_date_and_project_id(@activity.date, @activity.project_id)
      flash[:warning] = "You already have activity on selected project and date. Make sure that you didn't make a mistake."
      render :action => 'new_activity'
    elsif @activity.save
      flash[:notice] = 'Activity has been successfully created'
      redirect_to :action => 'activities_list'
    else
      render :action => 'new_activity'
    end
  end

  #
  # Fills form fields with recent activity
  # AJAX call
  #
  def recent_activity_js
    recent_activity = @current_user.activities.find_recent
    unless recent_activity.nil?
      recent_comments = escape_javascript(recent_activity.comments)
      recent_time = hour_format(recent_activity.minutes)
    end

    render :update do |page|
      page['activity_comments'].value = recent_comments
      page['activity_minutes'].value = recent_time
    end
  end

  #
  # Shows form with activity details to update
  # If activity has been invoiced, editing is not allowed
  #
  def edit_activity
    assert_params_must_have :id
    render :partial => "/users/no_permissions", :layout => "main" and return false unless @activity.editable_by? @current_user
    @projects = Project.find(:all)
  end

  #
  # Updates activity details. Data is validated before.
  #
  def update_activity
    assert_params_must_have :id
    render :partial => "/users/no_permissions", :layout => "main" and return false unless @activity.editable_by? @current_user

    @projects = Project.find(:all)
    # convert hours format to minutes
    params[:activity]['minutes'] = Activity.convert_duration(params[:activity]['minutes'])

    if @activity.update_attributes(params[:activity])
        flash[:notice] = 'Activity has been successfully updated'
        redirect_to :action => 'activities_list', :id => @activity
    else
        flash[:notice] = 'Errors with updating activities'
        render :action => 'edit_activity'
    end
  end

  #
  # Form with logged user's details to update
  #
  def edit_profile
    @user = @current_user
  end

  #
  # Updates user's details.
  #
  def update_profile
    @current_user.password_confirmation = @current_user.password
    if @current_user.update_attributes(:name => params[:user][:name], :email => params[:user][:email])
      flash[:notice] = 'Profile has been successfully updated'
      redirect_to :action => 'index'
    else
      @user = @current_user
      render :action => 'edit_profile'
    end
  end

  #
  # Shows form for updating password
  #
  def edit_password # user data form
    @user = @current_user
    @user.password = nil
    @user.password_confirmation = nil
  end

  #
  # Updates user's password.
  #
  def update_password
    assert_params_must_have :old_password

    # Check if old password matches
    unless @current_user.password_equals?(params[:old_password])
      @current_user.errors.add(:current_password, "is typed incorrectly")
      @user = @current_user
      render :action => 'edit_password' and return
    end

    # Load instance variables
    @user                       = @current_user
    @user.password              = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]

    # Try to update user information
    if @user.save
      flash[:notice] = 'Profile has been successfully updated'
      redirect_to :action => 'index'
    else
      flash[:notice] = 'Updating error'
      edit_password
      render :action => 'edit_password'
    end
  end

  #
  # Generetes data for statictics graph
  #
  def graph
    prepare_search_dates
    @activities = Activity.for_graph(params[:search].merge({:user_id => @current_user.id}))[:activities]
    session[:graph] = params[:search]
    @searched_project = Project.find(params[:search][:project_id]) rescue nil if params[:search][:project_id]
  end

  #
  # Generates XML data to for a flash graph
  #
  def graph_xml
    prepare_graph_xml(:user_id => @current_user.id, :is_invoiced => nil)

    @t = []
    for week in @weeks
      @t << [0] * (week.maxweek.to_i - week.minweek.to_i + 1)
    end

    @skip_level = @t.flatten.length / 10 - 3
    @skip_level = [0, @skip_level].max

    start_year = @years[0].minyear.to_i
    for act in @activities
      min_year = act.year.to_i - start_year
      @t[min_year][act.week.to_i - @weeks[min_year].minweek.to_i] = act.minutes.to_i
    end
  end

  def edit_rss_feed
    @feed = @current_user.rss_feed || @current_user.create_rss_feed
  end

  def update_rss_feed
    assert_params_must_have :authentication

    @feed = @current_user.rss_feed || @current_user.create_rss_feed
    @feed.authentication = params[:authentication] unless params[:authentication].blank?
    @feed.generate_random_key if @feed.authentication == 'key' && (@feed.secret_key.nil? || params[:regenerate_key] == '1')

    elements = params.reject {|k, v| v.blank?}.keys.collect(&:to_s)
    @feed.elements.clear
    for elem in elements
      begin
        @feed.elements << RssFeedElement.new_by_id(elem)
      rescue
        # either the class name or element id was incorrect - this shouldn't normally happen
      end
    end

    if @feed.save
      flash[:notice] = 'Your RSS feed has been successfully updated'
      redirect_to :action => 'edit_rss_feed'
    else
      flash[:error] = 'An error occured while updating the feed'
      render :action => 'edit_rss_feed'
    end
  end

  def rss
    render_rss_feed(Activity.find_for_managers_feed(@feed))
  end

end
