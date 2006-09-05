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
  before_filter :authorize # force authotization
  layout "main"

  # Default action.
  def index
    list
    render :action => 'list'
  end
  
  # Lists all current projects or specified by search conditions, if given.
  def list
    if !params[:search].nil?   
      cond = " 1 "
      if !params[:search][:name].blank?
        cond += " AND (projects.name LIKE \"%" + params[:search][:name] 
        cond += "%\" or projects.description LIKE \"%" + params[:search][:name] + "%\" )"
      end
      if !params[:search][:client].blank?
        cond += " AND clients.name LIKE \"%" + params[:search][:client] + "%\" "
      end
      @project_pages, @projects = paginate :project,:per_page => 10,
        :select => "projects.*, clients.name AS client_name",
        :joins => "LEFT JOIN clients ON projects.client_id = clients.id",
        :conditions => cond     
    else
      @project_pages, @projects = paginate :project, :per_page => 10
    end
    
  end
  
  # Shows chosen project with activities on its.
  def show
    begin
      @project = Project.find(params[:id])
    rescue
      flash[:notice] = "No such project"
      redirect_to :action => :index
    else
      @activities = Activity.find(
        :all, 
        :conditions => [ "project_id = (?)", params[:id]])
    end
  end
  
  # Project constructor.
  def new
    @project = Project.new
    @selected = {'client_id' => ''}
    if (@project.client)
      @selected['client_id']=@project.client.id.to_i
    end
  end
  
  # Creates new project and adds it to database.
  def create
    @project = Project.new(params[:project])
    @selected = {'client_id' => ''}
    if (@project.client)
      @selected['client_id']=@project.client.id.to_i
    end
    if @project.save
      flash[:notice] = 'Project has been successfully created'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end
  
  # Fills form with project's details to update.
  def edit
    begin
      @project = Project.find(params[:id])
    rescue
      flash[:notice] = "No such project"
      redirect_to :action => :index
    else
      @selected = {'client_id' => ''}
    if (@project.client)
      @selected['client_id']=@project.client.id.to_i
    end
    end
  end
  
  # Updates projects's details. Data is validated before.
  def update
    begin
      @project = Project.find(params[:id])
    rescue
      flash[:notice] = "No such project"
      redirect_to :action => :index
    else  
      @selected = {'client_id' => ''}
      if (@project.client)
        @selected['client_id']=@project.client.id.to_i
      end    
      if @project.update_attributes(params[:project])
        flash[:notice] = 'Project has been successfully updated'
      redirect_to :action => 'show', :id => @project
      else
        render :action => 'edit'
      end
    end
  end
  
  # Removes project. Not allowed.
  def destroy
    # Project.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
