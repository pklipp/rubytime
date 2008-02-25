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

class ClientsController < ApplicationController
  before_filter :authorize, :load_client
  layout "main"

private
  def load_client
    @client = Client.find( params[:id] ) if params[:id]
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "No such client"
      redirect_to :action => :index
  end

public
  #
  # Default action, render list action
  #
  def index
    list
    render :action => 'list'
  end
  
  #
  # Lists all clients using pagination
  #
  def list
    @clients = Client.paginate(:per_page => 10, :order => "is_inactive", :page => params[:page] || 1)
  end
  
  #
  # Searches clients for matching name or description
  #
  def search
    @clients = Client.search( params[:search] )
    render :partial => 'list' 
  end

  #
  # Shows details of chosen client.
  #
  def show
    assert_params_must_have :id
    @projects = @client.projects
  end

  #
  # Action to show new user form
  #
  def new
    @client = Client.new
  end

  #
  # Creates new client. Fills its details with data sent from html form
  #
  def create
    @client = Client.new(params[:client])
    if @client.save
      flash[:notice] = 'Client has been successfully created'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  #
  # Fills form with client's details to update.
  #
  def edit
    assert_params_must_have :id
  end

  #
  # Update user's details.
  #
  def update
    assert_params_must_have :id

    if @client.update_attributes(params[:client])
      flash[:notice] = 'Client has been successfully updated'
      redirect_to :action => 'show', :id => @client
    else
      render :action => 'edit'
    end
  end

  #
  # Displays client removal confirmation box
  # It requires admin to type client's name there in order to remove him
  #
  def confirm_destroy
    assert_params_must_have :id
  end

  #
  # Removes client after confirmation
  # If confirmation doesn't match it returns to list action with info in flash
  #
  def destroy
    assert_params_must_have :id
    
    # Do check confirmation
    if params[:name_confirmation] == @client.name
      result = @client.destroy
      if result
	     flash[:notice] = 'Client, his projects and activities have been deleted'
      else 
	     flash[:error] = 'Error occured while deleting client'
      end
    else
      flash[:error] = "The client has not been deleted, since the name was different" 
    end
    redirect_to :action => 'list'
  end
  
  #
  # Adds new client login to system
  # RJS action
  #
  def add_new_login
    assert_params_must_have :id
    
    # Try adding new client login to system, any exceptions will be presented to user
    begin
      @client_new_login           = ClientsLogin.new
      @client_new_login.login     = params[:new_login]
      @client_new_login.password  = Digest::SHA1.hexdigest(params[:new_password])
      @client_new_login.client_id = params[:id]
      @client_new_login.save!
      @result_text = "Client added!"
    rescue Exception => exc
      @result_text = "Error: #{exc.message}"      
    end    
    
    render :update do |page|
      page.replace_html "client_logins", :partial => "list_logins"
      page['client_login_result_text'].innerHTML = @result_text
      page.visual_effect :highlight, "client_login_result_text"
    end
  end
  
  # 
  # Removes client's login from system
  # RJS action 
  #
  def destroy_client_login    
    begin
      clients_login = ClientsLogin.find(params[:client_login_id])
      @client = Client.find(clients_login.client.id)
      if clients_login.destroy
        @result_text  = "Client's login #{clients_login.login} removed!"
      else
        @result_text  = "Error occured while deleting client's login"
      end
    rescue Exception => e
      @result_text  = "Error occured while deleting client's login: #{e}"
    end

    render :update do |page|
      page.replace_html "client_logins", :partial => "list_logins" unless @result_text =~ /^Error/
      page['client_login_result_text'].innerHTML = @result_text
      page.visual_effect :highlight, "client_login_result_text"
    end
  end

  #
  # Enables administrator to change client login details
  # RJS action
  #
  def change_clients_login_password
    begin
      clients_login           = ClientsLogin.find(params[:client_login_id])
      clients_login.password  = Digest::SHA1.hexdigest(params[:new_password])
      clients_login.save!
      @result_text = "Client's login " + clients_login.login + " password changed!"
    rescue Exception => exc
      @result_text = "Error: #{exc.message}"  
    end    
    
    render :update do |page|
      page['client_login_result_text'].innerHTML = @result_text
      page.visual_effect :highlight, "client_login_result_text"
    end
  end
  
end
