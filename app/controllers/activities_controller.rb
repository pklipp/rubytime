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

class ActivitiesController < ApplicationController
  helper :sparklines                    # sparklines helps with flash graphs
  before_filter :authorize              # force authorisation 
  layout "main", :except => :graph_xml  # graph_xml is loaded only by AJAX, no layout needed
  
  # Params filter provides reusable method prepare_search_dates
  require 'params_filter'
  include ParamsFilter

  #
  # Default action rendering list
  #
  def index
    list
    render :action => 'list'
  end
  
  #
  # Redirects to list of activitities or graph depending on submit button
  # with data specified by search conditions
  #
  def search
    case params[:commit]
      when "Search"
        list
        render :action => 'list'
      when "Export to CSV"
        report
      when "Generate graph"
        graph
        render :action => 'graph'
      else
        redirect_to :action => 'list'
    end
  end
  
  #
  # Lists all current activities or specified by search conditions.
  #
  def list 
     if(params[:search].nil? and session[:month].nil? and session[:year].nil?)
        # Return all activities, paginated
        @activities = Activity.list( {}, {:page=> params[:page]})
     else
        # Prepare params[:search] to be passed directly to Activity.list
        prepare_search_dates      
        
        # Get client and his not issued invoices if client is selected
        @client_id = Project.find(params[:search][:project_id]).client_id unless params[:search][:project_id].blank?
        @invoices = Invoice.find(:all, :conditions => ["client_id = ? AND is_issued=0", @client_id], :order => "created_at DESC")
    
        # Get list of activities meeting specified conditions
        @activities = Activity.list( params[:search] )
     end
  end
    
  #
  # Shows chosen activity
  #
  def show
    if ( @activity = Activity.find(params[:id]) ).nil?
      flash[:notice] = "No such activity"
      redirect_to :action => :index
    end
  end
  
  # Fills form with details of activities to update
#  def edit
#    begin
#      @activity = Activity.find(params[:id])
#      @projects = Project.find(:all)
#    rescue
#      flash[:notice] = "No such activity"
#      redirect_to :action => :index
#    else
#      @selected = {'project_id' => ''}
#      if (@activity.project)
#	@selected['project_id']=@activity.project.id.to_i
#      end
#    end
#  end
#  
#  # Updates activity
#  def update
#    begin
#      @activity = Activity.find(params[:id])
#      @projects = Project.find(:all)
#    rescue
#      flash[:notice] = "No such activity"
#      redirect_to :action => :index
#    else
#      @selected = {'project_id' => ''}
#      if (@activity.project)
#        @selected['project_id']=@activity.project.id.to_i
#      end
#      params[:activity]['minutes']= Activity.convert_duration(params[:activity]['minutes'])
#      if @activity.update_attributes(params[:activity])
#        flash[:notice] = 'Activity has been successfully updated'
#        redirect_to :action => 'show', :id => @activity
#      else
#        render :action => 'edit'
#      end
#    end
#  end
  
  #
  # Removes activity. Not allowed.
  #
  def destroy
    # Activity.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  #
  # Generetes data for statictics
  #
  def graph
    prepare_search_dates
    @activities = Activity.for_graph( params[:search] )[:activities]
    session[:graph] = params[:search]
  end
  
  #
  # Generates XML data for a graph
  #
  def graph_xml
    params[:search] = session[:graph]
    session[:graph] = nil
    
    prepare_search_dates
    query_results = Activity.for_graph( params[:search] )    
    
    @activities     = query_results[:activities]
    @grouped_roles  = query_results[:grouped_roles] 
    @weeks          = query_results[:weeks]
    @years          = query_results[:years]

  end
  
  #
  # Exports all selected activities to CSV file
  # Export is done in-memory basing on conditions in params[:search]
  # 
  def report
    prepare_search_dates
    activities = Activity.list( params[:search] )    
    
    require 'csv'
    
    report = StringIO.new
    minutes = 0 
    ::CSV::Writer.generate(report, ',') do |csv|
      header = ["Name", "Login", "Role", "Date", "Minutes"]
      header << "Comments" if params[:search] and params[:search][:details]
      csv << header
      activities.each do |activity|
        minutes += activity.minutes
	      data = [activity.project.name, activity.user.login, activity.date, activity.minutes]
	      data << activity.comments if params[:search] and params[:search][:details]
        csv << data 
      end
      csv << ["Sum", minutes]
    end

    report.rewind
    send_data(report.read,
      :type => 'text/csv; charset=utf-8; header=present',
      :filename => 'report.csv')
  end

  
  #used by remote call
  def show_activity_data
    @activity = Activity.find(params[:id])
    render :layout => false
  end
  
end


