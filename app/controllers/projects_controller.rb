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

class ProjectsController < ApplicationController
  before_filter :authorize, :load_project, :prepare_selected_hash # force authorization
  layout "main"

private
  #
  # Loads project if params[:id] is given. This method should be called in before_filter.
  #
  def load_project
    @project = Project.find( params[:id] ) if params[:id]

  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "No such project"
    redirect_to :action => :index    
  end
  
  #
  # Prepares selected hash, which is used in some views
  #
  def prepare_selected_hash
    @selected = {}
    @selected['client_id'] = @project.client.id.to_i if @project and @project.client
  end
  
public
  #
  # Default action. Renders list of projects
  #
  def index
    list
    render :action => 'list'
  end
  
  #
  # Lists all current projects, with pagination
  #
  def list
    @projects = Project.paginate(:per_page => 10, :order => "is_inactive", :page => params[:page] || 1)
  end
  
  #
  # Searches through projects using project name and client_id, rendering list of results
  #
  def search
    params[:search]||= {}
    
    @projects = Project.search( :name=> params[:search][:name], :client_id=> params[:search][:client_id] )   
    render :partial => 'list'
  end
  
  #
  # Shows chosen project with activities on it.
  #
  def show
    assert_params_must_have :id
    @activities = @project.activities
  end
  
  #
  # Shows new project form
  #
  def new
    @project = Project.new
    @clients = Client.find(:all)
  end
  
  #
  # Creates new project and adds it to database.
  #
  def create
    @project = Project.new(params[:project])
    @selected['client_id'] = @project.client.id if @project.client
    
    if @project.save
      flash[:notice] = 'Project has been successfully created'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
    
  end
  
  #
  # Shows form with project's details to update.
  #
  def edit
    assert_params_must_have :id
  end
  
  #
  # Updates projects's details. Data is validated before.
  #
  def update
    assert_params_must_have :id
        
    if @project.update_attributes(params[:project])
      flash[:notice] = 'Project has been successfully updated'
      redirect_to :action => 'show', :id => @project
    else
      render :action => 'edit'
    end    
  end

  #
  # Shows confirmation of deletion form for the project
  # Confirmation is based on writing project name in input field
  #
  def confirm_destroy
    assert_params_must_have :id
  end
  
  #
  # Removes project after confirmation.
  # Confirmation is based on writing project name in input field
  #
  def destroy
    assert_params_must_have :id
    
    if params[:name_confirmation] == @project.name
      flash[:notice]  = @project.destroy ? 'Project and it\'s activities have been deleted' : 'Error occured while deleting user' 
    else
      flash[:error]   = "The project has not been deleted, since the name was different" 
    end

    redirect_to :action => 'list'
  end
  
  #
  # Shows report by role for a project from selected time range
  #
  def report_by_role
    assert_params_must_have :id
    activities = Activity.find :all,
        :conditions => ['projects.id = ? and activities.date >= ? and activities.date <= ?', params[:id], params[:from_date], params[:to_date]],
        :include => [:user, :project],
        :order => "users.role_id",
        :joins => "left join roles on (users.role_id = roles.id)"
    @reports = []
    unless activities.blank?
      minutes_sum = 0
      last_role = activities.first.user.role
      for act in activities
        if act.user.role != last_role
          @reports << minutes_sum
          last_role = act.user.role
          minutes_sum = 0
        end
        @reports << act
        minutes_sum += act.minutes
      end
      @reports << minutes_sum
    end
  end

end
