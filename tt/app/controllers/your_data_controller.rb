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

class YourDataController < ApplicationController
  helper :sparklines
  before_filter :authorize
  layout "main", :except => :graph_xml
  
  # Default action. 
  def index 
    activities_list
    render :action => 'activities_list'
  end
  
  # Redirects to list of activitities or graph depending on submit button
  # with data specified by search conditions
  def search
    if params[:commit]=="Search"
      activities_list
      render :action => 'activities_list'
    elsif params[:commit]=="Generate graph"
      graph
      render :action => 'graph'
    else
      redirect_to :action => 'list'
    end
  end
  
  # Shows list of current user's activities
  def activities_list  
    @selected = { 'user_id' => '', 'project_id' => '', 'role_id' => ''} 
    conditions_string =" 1"; 
    # filter activities to current_user
    conditions_string +=" AND user_id='" + @current_user.id.to_s + "'"    
    # filter by project
    if (!params[:search].blank?)  
        conditions_string+= " AND project_id='" + params[:search]+ "'"
        @selected['project_id'] = params[:search]
    end
    # filter by year set in session 
    if (session[:year]) 
      conditions_string+= " AND YEAR(date)='" + session[:year] + "'"
    end
    # filter by month set in session 
    if (session[:month])
      conditions_string+= " AND MONTH(date)='" + session[:month] + "'"
    end
    @activity_pages, @activities = paginate :activity, 
                                            :per_page => 10,
                                            :conditions => conditions_string
                               
  end
  
  # Shows chosen activity.
  def show_activity 
    @activity = Activity.find(params[:id])
  end
  
  # Fill form for new activity.
  def new_activity 
    @activity = Activity.new
    @projects = Project.find_all
    @selected = {'project_id' => ''}
  end
  
  # creates new activity
  def create_activity
    if (params[:activity]['minutes'].index(':'))
      parts=params[:activity]['minutes'].split(/:/)
      params[:activity]['minutes']=parts[0].to_f + (parts[1].to_f / 60).to_f
    end
    
    params[:activity]['minutes']= params[:activity]['minutes'].to_f * 60
    @activity = Activity.new(params[:activity])
    @activity.user = User.find(session[:user_id]) # current user 
    @projects = Project.find_all
    
    @selected = {'project_id' => ''}
    if (@activity.project)
      @selected['project_id']=@activity.project.id.to_i
    end
    
    if @activity.save
      flash[:notice] = 'Activity has been successfully created'
      redirect_to :action => 'activities_list'
    else
      render :action => 'new_activity'
    end
  end
  
  # Fill form with activity's details to update
  def edit_activity 
    if @activity = Activity.find(:first, :conditions => [ "user_id = ? AND id= ?", @current_user.id, params[:id] ]) 
      @selected = {'project_id' => ''}
      if (@activity.project)
        @selected['project_id']=@activity.project.id.to_i
      end
    else
      render :partial => "users/no_permisions", :layout => "main" and return false      
    end
  end
  
  # Updates activity's details. Data is validated before. 
  def update_activity 
    @activity = Activity.find(params[:id])
    @projects = Project.find_all
    
    @selected = {'project_id' => ''}
    if (@activity.project)
      @selected['project_id']=@activity.project.id.to_i
    end
    # hours format to minutes
    if (params[:activity]['minutes'].index(':'))
      parts=params[:activity]['minutes'].split(/:/)
      params[:activity]['minutes']=parts[0].to_f + (parts[1].to_f / 60).to_f
    end
    params[:activity]['minutes']= params[:activity]['minutes'].to_f * 60

    if @activity.update_attributes(params[:activity])
      flash[:notice] = 'Activity has been successfully updated'
      redirect_to :action => 'activities_list', :id => @activity
    else
      render :action => 'edit_activity'
    end
  end
  
  # Fill form with logged user's details to update
  def edit_profile 
    @user = @current_user
  end
  
  # Updates user's details.
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
  
  # Fill form with logged user's details to update
  def edit_password # user data form 
    @user = @current_user
    @user.password=nil
    @user.password_confirmation=nil
  end
  
  # Updates user's password.
  def update_password 
    old_pass = User.hashed_pass(params[:old_password],@current_user.salt)
    if(old_pass == @current_user.password)
      @user = @current_user
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation] 
      if(@user.valid?)
        new_salt = User.create_new_salt
        new_pass = User.hashed_pass(params[:user][:password],new_salt)
        if @current_user.update_attributes(:password => new_pass, :salt => new_salt, :password_confirmation => new_pass) 
          flash[:notice] = 'Profile has been successfully updated'
          redirect_to :action => 'index'
        else
          flash[:notice] = 'Updating error'
          @user.password=nil
          @user.password_confirmation=nil
          render :action => 'edit_password'
        end
      else
        @user.password=nil
        @user.password_confirmation=nil
        render :action => 'edit_password'
      end
    else
      @current_user.errors.add(:Current_password, "is typed incorrectly") if (old_pass != @current_user.password)
      @user = @current_user
      @user.password=nil
      @user.password_confirmation=nil
      render :action => 'edit_password'
    end
  end
  
  # Generetes data for statictics
  def graph
    @selected = { 'project_id' => ''}
    conditions_string ="1=1 AND user_id='" + @current_user.id.to_s + "' ";
    if (!params[:search].blank?)
        conditions_string+= " AND project_id='" + params[:search] + "' "
        @selected['project_id'] = params[:search]
    end
    
    if (session[:year])
      conditions_string+= " AND YEAR(date)='" + session[:year] + "'"
    end
    if (session[:month])
      conditions_string += " AND MONTH(date)='" + session[:month] + "' "
    end

    @query = "SELECT "\
        + " SUM(minutes) minutes, YEAR(date) year, WEEK(date) week, user_id, role_id, MAX(date) maxdate " \
        + "FROM activities ac " \
        + "LEFT JOIN users us ON (ac.user_id=us.id)" \
        + "LEFT JOIN roles ro ON (us.role_id=ro.id)" \
        + "WHERE " \
        + conditions_string \
        + " GROUP BY YEAR(date), WEEK(date) " \
        + " ORDER BY YEAR(date), WEEK(date) "
    @activities = Activity.find_by_sql @query
    session[:graph] = params[:search]
  end
  
  # Generates XML data to for a graph
  def graph_xml
    params[:search] = session[:graph]
    session[:graph] = nil
    @selected = { 'project_id' => ''}
    conditions_string ="1=1 AND user_id='" + @current_user.id.to_s + "' ";
    if (!params[:search].blank?)
        conditions_string+= " AND project_id='" + params[:search] + "' "
        @selected['project_id'] = params[:search]
    end
    
    if (session[:year])
      conditions_string+= " AND YEAR(date)='" + session[:year] + "'"
    end
    if (session[:month])
      conditions_string += " AND MONTH(date)='" + session[:month] + "' "
    end
    
    @query = "SELECT "\
            + " SUM(minutes) minutes, YEAR(date) year, WEEK(date) week, user_id, role_id, MAX(date) maxdate " \
            + "FROM activities ac " \
            + "LEFT JOIN users us ON (ac.user_id=us.id) " \
            + "LEFT JOIN roles ro ON (us.role_id=ro.id) " \
            + "WHERE " \
            + conditions_string \
            + " GROUP BY YEAR(date), WEEK(date), role_id " \
            + " ORDER BY YEAR(date), WEEK(date), role_id " 
            
    @query3 = "SELECT  MAX(WEEK(date)) maxweek, MIN(WEEK(date)) minweek FROM activities ac "\
            + "LEFT JOIN users us ON (ac.user_id=us.id) "\
            + "LEFT JOIN roles ro ON (us.role_id=ro.id) "\
            + "WHERE "\
            + conditions_string
    
    @activities = Activity.find_by_sql @query
    @weeks = Activity.find_by_sql(@query3)

    @xm = Builder::XmlMarkup.new(:indent=>2, :margin=>4)
      @xm.chart {
        @xm.axis_category("size"=>"10", "alpha" => "75", "color"=>"ffffff", "orientation" => 'diagonal_up' )
        @xm.axis_ticks("value_ticks"=>'true', "category_ticks"=>"true", "major_thickness"=>"2", "minor_thickness"=>"1", "minor_count"=>"1", "major_color"=>"000000", "minor_color"=>"222222", "position"=>"outside")
        @xm.axis_value("font"=>'arial', "bold"=>'true', "size"=>'10', "color"=>"ffffff", "alpha"=>'75', "steps"=>'10', "suffix" => ' min' , "show_min"=>'true', "separator" => '', "orientation" => 'diagonal_up')
        @xm.chart_border("top_thickness" => '0', "bottom_thickness" => '1', "left_thickness" => '2', "right_thickness" => '0', "color" => '000000')
        if @activities.length>1
        @xm.chart_data(){
          @xm.row {
            @xm.null()
            (@weeks[0].minweek).upto(@weeks[0].maxweek) do |i|  
              @xm.string("week: " + i)
            end
          }
          duration = @weeks[0].maxweek.to_i - @weeks[0].minweek.to_i
          
          t=Array.new(duration+1,0)
          for act in @activities
              t[act.week.to_i - @weeks[0].minweek.to_i] = act.minutes.to_i
          end
              
          @xm.row {
            @xm.string("Your activities")
              for i in t
                @xm.number(i.to_s)
              end
          }
        }
        elsif @activities.length==1
          @xm.chart_data(){
          @xm.row {
            @xm.null()
            @xm.string("week: " + @weeks[0].minweek)
            @xm.string("week: " + @weeks[0].minweek)
          }                    
          @xm.row {
            @xm.string("Your activities")
                @xm.number(@activities[0].minutes)
                @xm.number(@activities[0].minutes)
          }
        }
        else
        @xm.chart_data(){
          @xm.row {
            @xm.null()
            @xm.string("0")
          }
          @xm.row {
            @xm.string("No activities found")
            @xm.number(0)
          }
        }
        end 
        @xm.chart_grid_h("alpha"=>'30', "color"=>'000000', "thickness"=>'1', "type"=>"solid") 
        @xm.chart_grid_v("alpha"=>'20', "color"=>'000000', "thickness"=>'1', "type"=>"dashed") 
        @xm.chart_pref("line_thickness"=>"2", "point_shape"=>"none", "fill_shape"=>'false') 
        @xm.chart_rect("x"=>'60', "y"=>'45', "width"=>'520', "height"=>'320', "positive_color"=>'000000', "positive_alpha"=>'20', "negative_color"=>'ff0000', "negative_alpha"=>'10')
        @xm.chart_type("Line")
        @xm.chart_value("position"=>'cursor', "size"=>'12', "color"=>'ffffff', "alpha"=>'75')
        @xm.chart_transition("type" => 'scale', "delay" => '0', "duration" => '1', "order" => 'series')
        @xm.chart_value("suffix" => ' min' )
        @xm.legend_label("size" => '10', "bullet" => 'circle')
        @xm.legend_rect("x"=>'60', "y"=>'10', "width"=>'400', "height"=>'10', "margin"=>'5')
        @xm.series_color{
          @xm.color("cc5511")
          @xm.color("77bb11")
          @xm.color("1155cc")  
        }
      }
  end
  
end
