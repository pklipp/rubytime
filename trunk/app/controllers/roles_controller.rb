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

class RolesController < ApplicationController
  before_filter :authorize, :load_role  # force authorisation 
  layout "main"
  
private
  #
  # Loads role if params[:id] is given. This method should be called in before_filter.
  #
  def load_role
    @role = Role.find( params[:id] ) if params[:id]
    
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "No such role"
    redirect_to :action => :index    
  end
  
public
  #
  # Default action. Renders all roles list
  #
  def index
    list
    render :action => 'list'
  end

  #
  # Lists all current roles.
  #
  def list
    @roles = Role.find(:all)
  end

  #
  # Shows chosen role details
  #
  def show
    assert_params_must_have :id
  end

  #
  # Shows new role form
  #
  def new
    @role = Role.new
  end

  #
  # Creates new role
  #
  def create
    params[:role][:short_name] = params[:role][:short_name].upcase
    @role = Role.new( params[:role] )

    if @role.save
      flash[:notice] = 'Role has been successfully created'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
    
  end

  #
  # Shows form for editing role
  # Form is filled with details to update.
  #
  def edit
    assert_params_must_have :id
  end

  #
  # Updates role details. Data is validated before.
  #
  def update
    assert_params_must_have :id

    if @role.update_attributes(params[:role])
      flash[:notice] = 'Role has been successfully updated'
      redirect_to :action => 'show', :id => @role
    else
      render :action => 'edit'
    end
    
  end
  
  #
  # Removes role. Not allowed.
  #
  def destroy
    # Role.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
