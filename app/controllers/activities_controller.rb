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
  
  # Default action
  def index
    list
    render :action => 'list'
  end
  
  # Redirects to list of activitities or graph depending on submit button
  # with data specified by search conditions
  def search
    case params[:commit]
      when "Search"
        list
        render :action => 'list'
      when "Export to CSV"
        list
        report
      when "Generate graph"
        graph
        render :action => 'graph'
      else
        redirect_to :action => 'list'
    end
  end
  
  # Lists all current projects or specified by search conditions
  def list 
     if(params[:search].nil? and session[:month].nil? and session[:year].nil?)
        # Return all activities, paginated
        @activity_pages, @activities = Activity.list( {}, {:current=> params[:page]})
     else
        # Prepare :search hash
        params[:search]||= {}
        params[:search][:default_month] = session[:month]
        params[:search][:default_year]  = session[:year]
      
        # Get client and his not issued invoices if client is selected
        @client_id = Project.find(params[:search][:project_id]).client_id unless params[:search][:project_id].blank?
        @invoices = Invoice.find(:all, :conditions => ["client_id = ? AND is_issued=0", @client_id], :order => "created_at DESC")
      
        # Create dates structure, holding start and end date of selected peroid
        dates = Struct.new( :date_from, :date_to ).new
        
        # Fill start date if selected on form
        if params[:dates] and not params[:dates][:date_from].blank?
          dates.date_from = params[:dates]["date_from(1i)"].to_i.to_s \
              + "-" + params[:dates]["date_from(2i)"].to_i.to_s \
              + "-" + params[:dates]["date_from(3i)"].to_i.to_s
        end

        # Fill end date if selected on form
        if params[:dates] and not params[:dates]['date_to(1i)'].blank?
          dates.date_to = params[:dates]["date_to(1i)"].to_i.to_s \
                    + "-" + params[:dates]["date_to(2i)"].to_i.to_s \
                    + "-" + params[:dates]["date_to(3i)"].to_i.to_s          
        end
    
        # Get list of activities meeting specified conditions
        @activities = Activity.list( params[:search].merge({:date_from=> dates.date_from, :date_to=> dates.date_to}) )
     end
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
      @projects = Project.find(:all)
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
      @projects = Project.find(:all)
    rescue
      flash[:notice] = "No such activity"
      redirect_to :action => :index
    else
      @selected = {'project_id' => ''}
      if (@activity.project)
        @selected['project_id']=@activity.project.id.to_i
      end
      params[:activity]['minutes']= Activity.convert_duration(params[:activity]['minutes'])
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
    list
    sqlweek = SqlFunction.get_week('date')
    sqlyear = SqlFunction.get_year('date')
    @query = "SELECT "\
        + " SUM(minutes) AS minutes, #{sqlyear} AS year, #{sqlweek} AS week, user_id, role_id, MAX(date) AS maxdate " \
        + "FROM activities ac " \
        + "LEFT JOIN users us ON (ac.user_id=us.id)" \
        + "LEFT JOIN roles ro ON (us.role_id=ro.id)" \
        + "WHERE " \
        + @conditions_string \
        + " GROUP BY year, week, role_id " \
        + " ORDER BY year, week, role_id " \

    @activities = Activity.find_by_sql @query
    session[:graph] = params[:search]
  end
  
  # Generates XML data to for a graph
  def graph_xml
    params[:search] = session[:graph]
    session[:graph] = nil
    list
    sqlweek = SqlFunction.get_week('date')
    sqlyear = SqlFunction.get_year('date')
    query = "SELECT "\
            + " SUM(minutes) AS minutes, #{sqlyear} AS year, #{sqlweek} AS week, user_id, role_id, MAX(date) AS maxdate " \
            + "FROM activities ac " \
            + "LEFT JOIN users us ON (ac.user_id=us.id) " \
            + "LEFT JOIN roles ro ON (us.role_id=ro.id) " \
            + "WHERE " \
            + @conditions_string \
            + " GROUP BY year, week, role_id " \
            + " ORDER BY year, week, role_id " 

    query2 = "SELECT  SUM(minutes) AS minutes,  role_id, ro.short_name FROM activities ac "\
            + "LEFT JOIN users us ON (ac.user_id=us.id) "\
            + "LEFT JOIN roles ro ON (us.role_id=ro.id) "\
            + "WHERE " \
            + @conditions_string \
            + " GROUP BY  role_id  ORDER BY role_id "
            
    query3 = "SELECT min( #{sqlyear} ) minyear, max( #{sqlyear} ) maxyear "\
            + "FROM activities ac "\
            + "LEFT JOIN users us ON (ac.user_id=us.id) "\
            + "LEFT JOIN roles ro ON (us.role_id=ro.id) "\
            + "WHERE "\
            + @conditions_string         
               
    query4 = "SELECT #{sqlyear} AS year, min( #{sqlweek} ) AS minweek, max( #{sqlweek} ) AS maxweek, COUNT(*)AS no_of_years "\
            + "FROM activities ac "\
            + "LEFT JOIN users us ON (ac.user_id=us.id) "\
            + "LEFT JOIN roles ro ON (us.role_id=ro.id) "\
            + "WHERE "\
            + @conditions_string \
            + " GROUP BY year"\
            + " ORDER BY year"
    
    @activities = Activity.find_by_sql(query)
    @grouped_roles  = Activity.find_by_sql(query2) 
    @weeks = Activity.find_by_sql(query4)
    @years = Activity.find_by_sql(query3)

    @xm = Builder::XmlMarkup.new(:indent=>2, :margin=>4)
      @xm.chart {
        skip_level = (@activities.length/10) - 2
        @xm.axis_category("size"=>"10", "alpha" => "75", "color"=>"ffffff", "orientation" => 'diagonal_up', "skip" => skip_level )
        @xm.axis_ticks("value_ticks"=>'true', "category_ticks"=>"true", "major_thickness"=>"2", "minor_thickness"=>"1", "minor_count"=>"1", "major_color"=>"000000", "minor_color"=>"222222", "position"=>"outside")
        @xm.axis_value("font"=>'arial', "bold"=>'true', "size"=>'10', "color"=>"ffffff", "alpha"=>'75', "steps"=>'10', "suffix" => ' min' , "show_min"=>'true', "separator" => '', "orientation" => 'diagonal_up')
        @xm.chart_border("top_thickness" => '0', "bottom_thickness" => '1', "left_thickness" => '2', "right_thickness" => '0', "color" => '000000')
        if @activities.length>1
        @xm.chart_data(){
          @xm.row {
            @xm.null()
            for week in @weeks
              (week.minweek.to_i).upto(week.maxweek.to_i) do |i|
                @xm.string("Year:" + week.year.to_s + ",Week:" + i.to_s)  
              end
            end
          }
          for roles in @grouped_roles           
            t = Array.new
            duration = 0
            for week in @weeks
              duration = week.maxweek.to_i - week.minweek.to_i
              t<< Array.new(duration+1,0)
            end

            for act in @activities
                if act.role_id==roles.role_id
                  minyear_id = act.year.to_i - @years[0].minyear.to_i
                  t[minyear_id][act.week.to_i - @weeks[minyear_id].minweek.to_i] = act.minutes.to_i
                end
            end
              @xm.row {
                label = roles.role.short_name.to_s
                @xm.string(label)
                for i in t
                  for j in i
                    @xm.number(j.to_s)
                  end
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
        @xm.chart_rect("x"=>'60', "y"=>'45', "width"=>'520', "height"=>'340', "positive_color"=>'000000', "positive_alpha"=>'20', "negative_color"=>'ff0000', "negative_alpha"=>'10')
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
  
  def report
    require 'csv'
    
    report = StringIO.new
    minutes = 0 
    ::CSV::Writer.generate(report, ',') do |csv|
      header = ["Name", "Login", "Role", "Date", "Minutes"]
      header << "Comments" if params[:search] and params[:search][:details]
      csv << header
      @activities.each do |activity|
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

end
