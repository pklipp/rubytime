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
  before_filter :authorize, :load_activity
  layout "main", :except => :graph_xml

  # Activity filter provides reusable method prepare_search_dates
  require 'params_filter'
  include ParamsFilter

private
  #
  # Loads project if params[:id] is given. This method should be called in before_filter.
  #
  def load_activity
    @activity = Activity.find( params[:id] ) if params[:id]

  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "No such activity"
    redirect_to :action => :index    
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
    case params[:commit]
      when "Search"
        activities_list
        render :action => 'activities_list'
      when "Generate graph"
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
    if params[:search].nil? and session[:month].nil? and session[:month].nil?
      @activities = Activity.list( {:user_id=> @current_user.id}, {:page=> params[:page], :per_page => 10}) 
    else
      prepare_search_dates
      @activities = Activity.list( params[:search] )
    end
  end

  #
  # Shows activities grid for choosen year & month (like calendar)
  #
  def activities_calendar
    session[:year] ||= Time.now.year.to_s 
    session[:month] ||= Time.now.month.to_s 
    activities_list
  end

  #
  # Shows chosen activity details
  #
  def show_activity
    assert_params_must_have :id
  end

  #
  # Shows form for new activity.
  #
  def new_activity
    @activity = Activity.new
    @activity.date = !params[:date].nil? ? Date.parse(params[:date]) : Date.today
    @projects = Project.find_active
    @activity.project_id = @current_user.activities.find(:first, :order => "id DESC").project_id unless @current_user.activities.empty?
  end

  #
  # Creates new activity based on information passed in form
  #
  def create_activity
    # Convert duration of activity to unified format
    params[:activity]['minutes']  = Activity.convert_duration(params[:activity]['minutes'])

    @activity         = Activity.new(params[:activity])
    @activity.user_id = @current_user.id
    @projects         = Project.find_active
    
    date = params[:activity]["date(1i)"].to_i.to_s \
          + "-" + params[:activity]["date(2i)"].to_i.to_s \
          + "-" + params[:activity]["date(3i)"].to_i.to_s
          

    # Warn user if he already has activity on the same project/date pair
    if @current_user.activities.find_by_date_and_project_id( date, params[:activity][:project_id] )
      flash[:warning] = "You already have activity on selected project and date. Make sure that you didn't make mistake."
    end

    if @activity.save
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
    @recent_activity = @current_user.activities.find(:first, :order => "id DESC") unless @current_user.activities.empty?
    unless @recent_activity.nil?
      @recent_comments  = escape_javascript(@recent_activity.comments)
      @recent_time      = hour_format(@recent_activity.minutes)
    end

    render :update do 
      |page|
      page<< "$('activity_comments').value = '#{@recent_comments}'"
      page<< "$('activity_minutes').value = '#{@recent_time}'"
    end
  end

  #
  # Shows form with activity details to update
  # If activity has been invoiced, editing is not allowed
  #
  def edit_activity
    assert_params_must_have :id

    # do not allow editing of other's or invoiced activities 
    if @activity.user_id != @current_user.id or @activity.invoice_id
        render :inline=> "<div id=\"errorNotice\">You have no permisions to view this page!</div>", :layout => "main" and return false
    end
    
    @projects = Project.find_active
  end

  #
  # Updates activity details. Data is validated before.
  #
  def update_activity
    assert_params_must_have :id

    # do not allow editing of other's or invoiced activities 
    if @activity.user_id != @current_user.id or @activity.invoice_id
      render :inline=> "<div id=\"errorNotice\">You have no permisions to view this page!</div>", :layout => "main" and return false
      return
    end
    
    @projects = Project.find_active
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
    if (@current_user.update_attributes(:name => params[:user][:name], :email => params[:user][:email]))
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
      @user.password=nil
      @user.password_confirmation=nil
  end

  #
  # Updates user's password.
  #
  def update_password
    assert_params_must_have :old_password
    
    # Check if old password matches
    unless @current_user.password_equals?( params[:old_password] )
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
      @user.password = nil
      @user.password_confirmation=nil
      render :action => 'edit_password'
    end
  end

  #
  # Generetes data for statictics graph
  #
  def graph        
    prepare_search_dates
    @activities = Activity.for_graph( params[:search].merge({:user_id=> @current_user.id}) )[:activities]
    session[:graph] = params[:search]
  end

  #
  # Generates XML data to for a flash graph
  #
  def graph_xml
    params[:search] = session[:graph]
    session[:graph] = nil
    
    prepare_search_dates
    query_results = Activity.for_graph( params[:search].merge({:user_id=> @current_user.id, :is_invoiced=> nil}) )    

    @activities     = query_results[:activities] 
    @weeks          = query_results[:weeks]
    @years          = query_results[:years]

    @t = Array.new
    duration = 0
    for week in @weeks
        duration = week.maxweek.to_i - week.minweek.to_i
        @t<< Array.new(duration+1, 0)
    end

    @skip_level=(@t.flatten.length/10)-3
    @skip_level=0 if @skip_level<0

    for act in @activities
        minyear_id = act.year.to_i - @years[0].minyear.to_i
        @t[minyear_id][act.week.to_i - @weeks[minyear_id].minweek.to_i] = act.minutes.to_i
    end
  end

end
