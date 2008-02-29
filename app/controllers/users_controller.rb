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

class UsersController < ApplicationController
  before_filter :authorize, :load_user
  layout "main"

private
  #
  # Loads user if params[:id] is given. This method should be called in before_filter.
  #
  def load_user
    @user = User.find( params[:id] ) if params[:id]
    
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "User not found"
    redirect_to :action => :index 
  end
  
public
  #
  # Default action. Renders users list
  #
  def index
    list
    render :action => 'list'
  end
  
  #
  # Lists all users using pagination
  #
  def list
    @users = User.paginate(:per_page => 10, :order => "is_inactive", :page => params[:page] || 1)
  end
  
  #
  # Searches for users
  # searched text is directly passed in params[:search]
  #
  def search
    @users = User.search( params[:search].to_s )
    render :partial => 'list'
  end
  
  #
  # Shows new user form
  #
  def new
    @user = User.new
  end
 
  #
  # Creates new user basing on params passed in form
  # params[:user]
  #
  def create
    @user = User.new( params[:user] )  
    
    if(@user.valid?)
      @user.password = params[:user][:password]
      @user.password_confirmation = @user.password  
      if @user.save
        flash[:notice] = 'User has been successfully created'
        redirect_to :action => 'list'
      else
        flash[:notice] = 'Updating error'
        @user.password = nil
        @user.password_confirmation = nil
        render :action => 'new'
      end
    else
      @user.password = nil
      @user.password_confirmation = nil
      render :action => 'new'
    end
  
  end
  
  #
  # Updates user's details.
  #
  def update
    assert_params_must_have :id

    if @user == @current_user
      # don't allow to deactivate the current user
      params[:user].delete(:is_inactive)
    end

    @selected = {'role_id' => ''}
    if (@user.role)
      @selected['role_id']=@user.role.id.to_i
    end

    if @user.update_attributes(params[:user])
      flash[:notice] = 'User has been successfully updated'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end 
  end
  
  #
  # Shows form with details of specified user to update
  #
  def edit
    assert_params_must_have :id
  end
  
  #
  # Updates user's password.
  #
  def update_password
    assert_params_must_have :id

    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]

    if(@user.valid?)
      if @user.save
        flash[:notice] = "Password has been succesfully updated "
        redirect_to :action => :index   
      else
        flash[:notice] = "Updating error"
        @user.password = nil
        @user.password_confirmation = nil
        render :action => 'edit_password'
      end
    else
      @user.password = nil
      @user.password_confirmation = nil
      render :action => 'edit_password'
    end 
  end

  #
  # Shows form with password update field
  #
  def edit_password
    assert_params_must_have :id
  end

  #
  # Shows details on user activities
  #
  def show
    assert_params_must_have :id
    @activities = @user.activities
  end

  #
  # Shows destroy confirmation form
  # Admin is required to type username before destroy
  # Administrators +can't+ be removed using this method
  #
  def confirm_destroy
    assert_params_must_have :id
    
    # Do not allow to remove admins
    if @user.is_admin?
      flash[:error] = "Admin can't be deleted"
      redirect_to :action => "list"
    end
    
  end

  #
  # Removes user after confirmation
  # Administrators +can't+ be removed using this method
  #
  def destroy
    assert_params_must_have :id
    
    # Check if we are not trying to remove admin
    if @user.is_admin?
      flash[:error] = "Admin can't be deleted"
      redirect_to :action => "list" and return
    end
    
    # Check if confirmation matches
    if params[:name_confirmation] == @user.name
      @user.destroy ? flash[:notice] = 'User and his activities have been deleted' : 
                      flash[:error] = 'Error occured while deleting user'
    else
      flash[:error] = "The user has not been deleted, since the name was different" 
    end
    
    redirect_to :action => 'list'
  end

end
