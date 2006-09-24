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
  before_filter :authorize
  layout "main"
  
  # Default action.
  def index
    list
    render :action => 'list'
  end
  
  # Lists all users or specified by search conditions.
  def list
      @user_pages, @users = paginate :user, :per_page => 10, :order => "is_inactive"
  end
  
  #Searches users.
  def search
      query = " 1 AND login LIKE \"%" + params[:search] + "%\" OR name LIKE \"%" + params[:search] + "%\" "
      @users = User.find(:all,:conditions => query, :order => "is_inactive")
      render :partial => 'list'
  end
  
  # User constructor.
  def new
    @user = User.new
  end
 
  # Creates new user.
  def create
    @user = User.new(params[:user])  
    if(@user.valid?)
      new_salt = User.create_new_salt
      @user.salt = new_salt
      @user.password = User.hashed_pass(params[:user][:password],new_salt)
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
  
  # Updates user's details.
  def update
    begin
      @user = User.find(params[:id])
    rescue
      flash[:notice] = "Updating error"
      redirect_to :action => :index 
    else
      @selected = {'role_id' => ''}
      if (@user.role)
        @selected['role_id']=@user.role.id.to_i
      end
      @user.password_confirmation = @user.password
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User has been successfully updated'
        redirect_to :action => 'list'
      else
        render :action => 'edit'
      end 
    end
  end
  
  # Fills form with details of specified user to update
  def edit
    begin
      @user = User.find(params[:id])
    rescue
      flash[:notice] = "No such user"
      redirect_to :action => :index
    end
  end
  
  # Updates user's password.
  def update_password
    begin
      @user = User.find(params[:id])
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
    rescue
      flash[:notice] = "Updating error"
      redirect_to :action => :index
    else
      if(@user.valid?)
        new_salt = User.create_new_salt
        new_pass = User.hashed_pass(params[:user][:password],new_salt)
        if @user.update_attributes(:password => new_pass, 
                                  :salt => new_salt, 
                                  :password_confirmation => new_pass)
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
  end

  # Fills form with details of specified user to update
  def edit_password
    begin
      @user = User.find(params[:id])
      @user.password = nil
    rescue
      flash[:notice] = "No such user"
      redirect_to :action => :index 
    end
  end

  # Shows details of chosen role.
  def show
    begin
      @user = User.find(params[:id])
    rescue
      flash[:notice] = "No such user"
      redirect_to :action => :index
    else  
      @activities = Activity.find(:all, 
        :conditions => [ "user_id = (?)", params[:id]])
    end
  end

  # Removes user
  def destroy
    if User.find(params[:id]).destroy
      flash[:notice] = "User and his activities have been deleted"
    else
      flash[:notice] = "Error with deleting user"
    end
    redirect_to :action => 'list'
  end

end
