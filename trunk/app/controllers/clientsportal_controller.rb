# ----------------------------------------------------------------------------
# This controller is responsible for delivering read-only info for clients.
# Access to this controller is separated from other Time Tracker pages.
#
# author: Wiktor Gworek
# ----------------------------------------------------------------------------

class ClientsportalController < ApplicationController
    include CalendarHelper

    before_filter :authorize_client, :except => ["login", "logout", "rss"]
    before_filter :prepare_data_for_rss_form, :only => ['edit_rss_feed', 'update_rss_feed']
    before_filter :authorize_client_to_feed, :only => :rss
    layout "clientportal"
    helper :your_data

    #
    # Displays welcome screen.
    #
    def index
        @client_name = @current_client.name
        render :action => "index"
    end

    #
    # Action is responsible for logging client. 
    # If successful then user is redirected to index action.
    #
    def login
        if request.get?
            session[:client_id] = nil
            @log_client = ClientsLogin.new
        else
            logged_in_client = ClientsLogin.authorize(params[:log_client][:login], params[:log_client][:password])
            if logged_in_client.kind_of? Client
                if logged_in_client.is_inactive?
                    flash[:error] = "Your account is currently inactive"
                else
                    session[:client_id] = logged_in_client.id
                    session[:client_login] = params[:log_client][:login]
                    redirect_to(:action => "index")
                end
            else
                session[:client_id] = nil
                flash[:error] = "Invalid client login/password combination"
            end
        end
    end

    #
    # Logging out client and redirecting to login page.
    #
    def logout
        session[:client_id] = nil
        flash[:notice] = "Client logged out"
        redirect_to(:action => "login")
    end

    #
    # Showing logged client profile.
    #
    def show_profile
      @client = @current_client
      render :action => "show_profile"
    rescue
      flash[:notice] = "No such client"
      redirect_to :action => :index
    end

    #
    # Showing logged client his/her projects.
    #
    def show_projects
      @client = @current_client
      @projects = @client.projects
      render :action => "show_projects"
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "No such client"
      redirect_to :action => :index
    end

    #
    # Showing client's selected project details. Client cannot see not his/her
    # projects.
    #
    def show_project
      @project = @current_client.projects.find( params[:id] )
      @activities = @project.activities
      render :layout => false
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "No such project"
      redirect_to :action => "index"
    end

    #
    # Showing calendar with project activities. Client cannot see activities
    # of other client's projects.
    #
    def show_project_activities
      @project = @current_client.projects.find(params[:project_id])
      session[:year] ||= Time.now.year.to_s
      session[:month] ||= Time.now.month.to_s

      @activities = Activity.project_activities(@project.id, session[:month], session[:year])
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "No such project"
      redirect_to :action => "index"
    end

    #
    # Showing details of selected activity.
    #
    def show_activity
      @activity = Activity.find( params[:id] )
      raise ActiveRecord::RecordNotFound unless @activity.project.client == @current_client
      render :layout => false if params[:embed]
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "No such activity"
      redirect_to :action => :index
    end

    #
    # Showing client ISSUED ONLY invoices.
    #
    def show_invoices
      @invoices = @current_client.invoices.find_all_by_is_issued(true)
      render :action => "show_invoices"
    end

    #
    # Showing details of selected invoice.
    #
    def show_invoice
      @invoice = @current_client.invoices.find( params[:id] )
      render :layout => false if params[:embed]
    rescue
      flash[:notice] = "No such invoice"
      redirect_to :action => :index
    end

    #
    # Showing fields for changing client's password.
    #
    def edit_client_password
      @clients_login = @current_client.clients_logins.find_by_login( session[:client_login] )
      render :layout => false
    rescue
      flash[:notice] = "No such client"
      redirect_to :action => :index
    end

    #
    # Updates client password if everything is OK and redirects to show_profile.    
    #
    def update_client_password
        @client_login = @current_client.clients_logins.find_by_login( session[:client_login] )
        
        # Check if client login has been found
        if @client_login.nil?
          flash[:error] = "We are sorry, but your login was removed by administrator"
          redirect_to :action => 'logout' and return            
        end
#        unless @client_login.password_equals? params[:old_password]
#          flash[:error] = "Current password is typed incorrectly"
#          redirect_to :action => 'edit_client_password' and return  
#        end
        @client_login.force_checking_password = true
        if @client_login.update_attributes(params[:client_login])
          flash[:notice] = 'Individual password has been successfully updated'
          redirect_to :action => 'show_profile'
        else
          render :action => :edit_client_password
        end
      end

    def show_activities
      @activities = @current_client
    end
    
    def time_period
      render :layout => false
    end

    def report_by_role
      assert_params_must_have :id
      @project = Project.find(params[:id])
      @reports = @project.create_report_by_role(params[:from_date], params[:to_date])
      render :layout => false
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "No such project"
      redirect_to :action => :index
    end

    def show_activity_data
      @activity = Activity.find(params[:id])
      render :layout => false
    end



    def edit_rss_feed
    end

    def update_rss_feed
      assert_params_must_have :authentication

      @feed.authentication = params[:authentication] unless params[:authentication].blank?
      @feed.generate_random_key if @feed.authentication == 'key' && (@feed.secret_key.nil? || params[:regenerate_key] == '1')

      @feed.elements.clear
      for project in @projects
        unless params["project_#{project.id}".to_sym].blank?
          @feed.elements.create(:project => project)
        else
          for role in @roles
            unless params["role_#{project.id}_#{role.id}".to_sym].blank?
              @feed.elements.create(:project => project, :role => role)
            else
              for user in @project_users[project][role]
                @feed.elements.create(:project => project, :user => user) unless params["user_#{project.id}_#{user.id}".to_sym].blank?
              end
            end
          end
        end
      end

      if @feed.save
        flash[:notice] = 'Your RSS feed has been successfully updated'
        redirect_to :action => 'edit_rss_feed'
      else
        flash[:error] = 'An error occured while updating the feed'
        render :action => 'edit_rss_feed'
      end
    end

    def rss
      activities = Activity.find :all,
        :joins => "INNER JOIN users ON (users.id = activities.user_id)
          LEFT JOIN rss_feed_elements AS fp ON
            (fp.project_id = activities.project_id AND fp.rss_feed_id = #{@feed.id} AND fp.user_id IS NULL AND fp.role_id IS NULL)
          LEFT JOIN rss_feed_elements AS fu ON
            (fu.project_id = activities.project_id AND fu.user_id = activities.user_id AND fu.rss_feed_id = #{@feed.id} AND fu.role_id IS NULL)
          LEFT JOIN rss_feed_elements AS fr ON
            (fr.project_id = activities.project_id AND fr.role_id = users.role_id AND fr.rss_feed_id = #{@feed.id} AND fr.user_id IS NULL)",
        :conditions => ["(fp.id IS NOT NULL OR fu.id IS NOT NULL OR fr.id IS NOT NULL) AND activities.created_at >= ? AND activities.created_at < ?",
            Time.now.midnight - 2.weeks, Time.now.midnight]

      render_rss_feed(activities)
    end

    private

    def prepare_data_for_rss_form
      @feed = @current_client.rss_feed || @current_client.create_rss_feed
      @projects = Project.find_active_for_client(@current_client)
      @roles = Role.find :all, :order => 'name'
      @project_users = {}
      @expand_project = {}
      @expand_role = {}
      for project in @projects
        @project_users[project] = {}
        @expand_role[project] = {}
        users = User.find_involved_in_project(project)
        @expand_project[project] = !@feed.elements.users_in_project(project).empty? || !@feed.elements.roles_in_project(project).empty?
        for role in @roles
          @project_users[project][role] = users.find_all {|u| u.role == role}
          @expand_role[project][role] = @project_users[project][role].any? {|u| @feed.elements.users_in_project(project).include?(u.id)}
        end
      end
    end

    def authorize_client_to_feed
      authorize_to_feed :current_user => Proc.new {@current_client},
        :authorize => Proc.new {authorize_client},
        :http_check => Proc.new {|login, pass| client = ClientsLogin.authorize(login, pass) and !client.is_inactive? and @feed.owner == client}
    end

end
