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

class ActivitiesController < ApplicationController
  helper :sparklines
  before_filter :authorize              # force authorisation 
  layout "main", :except => :graph_xml  # graph_xml is loaded only by AJAX, no layout needed
  
  # Default action
  def index
    list
    render :action => 'list'
  end
  
  # Redirects to list of activitities or graph depending on submit button
  # with data specified by search conditions
  def search
    if params[:commit]=="Search"
      list
      render :action => 'list'
    elsif params[:commit]=="Generate graph"
      graph
      render :action => 'graph'
    else
      redirect_to :action => 'list'
    end
  end
  
  #Lists all current projects or specified by search conditions
  def list 
    @selected = { 'user_id' => '', 'project_id' => '', 'role_id' => '' }
    
    conditions_string =" 1 ";
    
    if (!params[:search].nil?)
    date_from = params[:search]["date_from(1i)"].to_i.to_s \
              + "-" + params[:search]["date_from(2i)"].to_i.to_s \
              + "-" + params[:search]["date_from(3i)"].to_i.to_s
    date_to = params[:search]["date_to(1i)"].to_i.to_s \
              + "-" + params[:search]["date_to(2i)"].to_i.to_s \
              + "-" + params[:search]["date_to(3i)"].to_i.to_s          
    
      if (!params[:search][:role_id].blank?)
        conditions_string+= " AND ((SELECT role_id FROM users WHERE users.id=user_id)='" + params[:search]['role_id']+ "')"
        @selected['role_id'] = params[:search][:role_id]
      end

      if (!params[:search][:user_id].blank?)
        conditions_string+= " AND user_id='" + params[:search][:user_id]+ "'"
        @selected['user_id'] = params[:search][:user_id]
      end
      if (!params[:search][:project_id].blank?)
        conditions_string+= " AND project_id='" + params[:search][:project_id]+ "'"
        @selected['project_id'] = params[:search][:project_id]
      end

      if (!params[:search]['date_from(1i)'].blank?)
        conditions_string+= " AND date >= '" + date_from + "'"
      end
      if (!params[:search]['date_to(1i)'].blank?)
        conditions_string+= " AND date <= '" + date_to + "'"
      end
    end 

     if (params[:search].nil? or (params[:search]['date_from(1i)'].blank? and !params[:search]['date_t1i)'].blank?))
       if (session[:year])
         conditions_string+= " AND YEAR(date)='" + session[:year] + "'"
       end
       if (session[:month])
         conditions_string += " AND MONTH(date)='" + session[:month] + "' "
       end
     end
     
      @activity_pages, @activities = paginate :activity, 
                                              :per_page => 10,
                                              :conditions => conditions_string
  end
  
  # Lists current user's activities
  def your_list
    list(" AND user_id='" + @current_user.id.to_s + "'")
    render :action => "list"
  end
  
  # Shows chosen activity
  def show
    begin
    @activity = Activity.find(params[:id])
    rescue
    flash[:notice] = "No such activity"
    redirect_to :action => :index
    end
  end
  
  # Activity constructor
  def new
    @activity = Activity.new
    @projects = Project.find_all
    @selected = {'project_id' => ''}
  end
  
  # Creates new activity
  def create
    @activity = Activity.new(params[:activity])
    @activity.user = User.find(session[:user_id])
    @projects = Project.find_all
    
    @selected = {'project_id' => ''}
    if (@activity.project)
      @selected['project_id']=@activity.project.id.to_i
    end
    
    if @activity.save
      flash[:notice] = 'Activity has been successfully created'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end
  
  # Fills form with details of activities to update
  def edit
    begin
    @activity = Activity.find(params[:id])
    @projects = Project.find_all
    rescue
    flash[:notice] = "No such activity"
    redirect_to :action => :index
    else
    @selected = {'project_id' => ''}
    if (@activity.project)
      @selected['project_id']=@activity.project.id.to_i
    end
    end
  end
  
  # Updates activity
  def update
    begin
    @activity = Activity.find(params[:id])
    @projects = Project.find_all
    rescue
    flash[:notice] = "No such activity"
    redirect_to :action => :index
    else
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
      redirect_to :action => 'show', :id => @activity
    else
      render :action => 'edit'
    end
    end
  end
  
  # Romoves activity. Not allowed.
  def destroy
    # Activity.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  # Generetes data for statictics
  def graph
    @selected = { 'user_id' => '', 'project_id' => '', 'role_id' => ''}
    conditions_string =" 1 ";
    if (!params[:search].nil?)
       date_from = params[:search]["date_from(1i)"].to_i.to_s \
              + "-" + params[:search]["date_from(2i)"].to_i.to_s \
              + "-" + params[:search]["date_from(3i)"].to_i.to_s
      date_to = params[:search]["date_to(1i)"].to_i.to_s \
              + "-" + params[:search]["date_to(2i)"].to_i.to_s \
              + "-" + params[:search]["date_to(3i)"].to_i.to_s 
      if (!params[:search][:role_id].blank?)
        conditions_string+= " AND ((SELECT role_id FROM users WHERE users.id=user_id)='" + params[:search]['role_id']+ "')"
        @selected['role_id'] = params[:search][:role_id]
      end
      if (!params[:search][:user_id].blank?)
        conditions_string+= " AND user_id='" + params[:search][:user_id]+ "'"
        @selected['user_id'] = params[:search][:user_id]
      end
      if (!params[:search][:project_id].blank?)
        conditions_string+= " AND project_id='" + params[:search][:project_id]+ "'"
        @selected['project_id'] = params[:search][:project_id]
      end
      if (!params[:search]['date_from(1i)'].blank?)
        conditions_string+= " AND date >= '" + date_from + "'"
      end
      if (!params[:search]['date_to(1i)'].blank?)
        conditions_string+= " AND date <= '" + date_to + "'"
      end
    end
    
    if (params[:search]['date_from(1i)'].blank? and params[:search]['date_to(1i)'].blank?)
       if (session[:year])
         conditions_string+= " AND YEAR(date)='" + session[:year] + "'"
       end
       if (session[:month])
         conditions_string += " AND MONTH(date)='" + session[:month] + "' "
       end
    end

    @query = "SELECT "\
        + " SUM(minutes) minutes, YEAR(date) year, WEEK(date) week, user_id, role_id, MAX(date) maxdate " \
        + "FROM activities ac " \
        + "LEFT JOIN users us ON (ac.user_id=us.id)" \
        + "LEFT JOIN roles ro ON (us.role_id=ro.id)" \
        + "WHERE " \
        + conditions_string \
        + " GROUP BY YEAR(date), WEEK(date), role_id " \
        + " ORDER BY YEAR(date), WEEK(date), role_id " \

    @activities = Activity.find_by_sql @query
    session[:graph] = params[:search]
  end
  
  # Generates XML data to for a graph
  def graph_xml
    params[:search] = session[:graph]
    session[:graph] = nil
    @selected = { 'user_id' => '', 'project_id' => '', 'role_id' => ''}
    conditions_string =" 1 ";
    if (!params[:search].nil?)
       date_from = params[:search]["date_from(1i)"].to_i.to_s \
              + "-" + params[:search]["date_from(2i)"].to_i.to_s \
              + "-" + params[:search]["date_from(3i)"].to_i.to_s
      date_to = params[:search]["date_to(1i)"].to_i.to_s \
              + "-" + params[:search]["date_to(2i)"].to_i.to_s \
              + "-" + params[:search]["date_to(3i)"].to_i.to_s 
      if (!params[:search][:role_id].blank?)
        conditions_string+= " AND ((SELECT role_id FROM users WHERE users.id=user_id)='" + params[:search]['role_id']+ "')"
        @selected['role_id'] = params[:search][:role_id]
      end
      if (!params[:search][:user_id].blank?)
        conditions_string+= " AND user_id='" + params[:search][:user_id]+ "'"
        @selected['user_id'] = params[:search][:user_id]
      end
      if (!params[:search][:project_id].blank?)
        conditions_string+= " AND project_id='" + params[:search][:project_id]+ "'"
        @selected['project_id'] = params[:search][:project_id]
      end
      if (!params[:search]['date_from(1i)'].blank?)
        conditions_string+= " AND date >= '" + date_from + "'"
      end
      if (!params[:search]['date_to(1i)'].blank?)
        conditions_string+= " AND date <= '" + date_to + "'"
      end
    end
    
    if (params[:search]['date_from(1i)'].blank? and params[:search]['date_to(1i)'].blank?)
       if (session[:year])
         conditions_string+= " AND YEAR(date)='" + session[:year] + "'"
       end
       if (session[:month])
         conditions_string += " AND MONTH(date)='" + session[:month] + "' "
       end
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

    @query2 = "SELECT  SUM(minutes) minutes,  role_id, ro.short_name FROM activities ac "\
            + "LEFT JOIN users us ON (ac.user_id=us.id) "\
            + "LEFT JOIN roles ro ON (us.role_id=ro.id) "\
            + "WHERE " \
            + conditions_string \
            + " GROUP BY  role_id  ORDER BY role_id "
            
    @query3 = "SELECT  MAX(WEEK(date)) maxweek, MIN(WEEK(date)) minweek FROM activities ac "\
            + "LEFT JOIN users us ON (ac.user_id=us.id) "\
            + "LEFT JOIN roles ro ON (us.role_id=ro.id) "\
            + "WHERE "\
            + conditions_string
    
    @activities = Activity.find_by_sql @query
    @grouped_roles  = Activity.find_by_sql @query2 
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
          for roles in @grouped_roles           
              t=Array.new(duration+1,0)
              for act in @activities
                if act.role_id==roles.role_id
                  t[act.week.to_i - @weeks[0].minweek.to_i] = act.minutes.to_i
                end
              end
              
              @xm.row {
                label = roles.role.short_name.to_s
                @xm.string(label)
                for i in t
                  @xm.number(i.to_s)
                end
              }
          end 
        }
        elsif @activities.length==1
          @xm.chart_data(){
          @xm.row {
            @xm.null()
            @xm.string("week: " + @weeks[0].minweek)
            @xm.string("week: " + @weeks[0].minweek)
          }                    
          @xm.row {
            @xm.string(@grouped_roles[0].short_name)
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
          @xm.color("F0F030")
          @xm.color("1155cc")
          @xm.color("D100D1")  
        }
      }
  end

end
