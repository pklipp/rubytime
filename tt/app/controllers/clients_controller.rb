# ************************************************************************
# Time Tracker
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

class ClientsController < ApplicationController
  before_filter :authorize
  layout "main"

  # Default action, render list action
  def index
    list
    render :action => 'list'
  end

  # Lists all clients or specified by search conditions.
  def list
    if !params[:search].nil?
      query = " 1 AND name LIKE \"%" + params[:search] + "%\" OR description LIKE \"%" + params[:search] + "%\" "
      @client_pages, @clients = paginate :client, 
                                         :per_page => 10,
                                         :conditions => query
    else
      @client_pages, @clients = paginate :client, :per_page => 10
    end
  end

  # Shows details of chosen client.
  def show
    begin
      @client = Client.find(params[:id])
    rescue
      flash[:notice] = "No such client"
      redirect_to :action => :index
    end
  end

  # Action to show new user form
  def new
    @client = Client.new
  end

  # Creates new client. Fills its details with data sent from html form
  def create
    @client = Client.new(params[:client])
    if @client.save
      flash[:notice] = 'Client has been successfully created'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  # Fills form with client's details to update.
  def edit
    begin
      @client = Client.find(params[:id])
    rescue
      flash[:notice] = "No such client"
      redirect_to :action => :index
    end
  end

  # Update user's details.
  def update
    begin
      @client = Client.find(params[:id])
    rescue
      flash[:notice] = "No such client"
      redirect_to :action => :index
    else
      if @client.update_attributes(params[:client])
        flash[:notice] = 'Client has been successfully updated'
        redirect_to :action => 'show', :id => @client
      else
        render :action => 'edit'
      end
    end
  end

  # Removes client. Not allowed.
  def destroy
    # Client.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
end
