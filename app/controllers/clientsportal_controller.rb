# ----------------------------------------------------------------------------
# This controller is responsible for delivering read-only info for clients.
# Access to this controller is separated from other Time Tracker pages.
#
# author: Wiktor Gworek
# ----------------------------------------------------------------------------

class ClientsportalController < ApplicationController
    include CalendarHelper
  
    before_filter :authorize_client, :except => ["login", "logout"]
    layout "clientportal"

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
                session[:client_id] = logged_in_client.id
                session[:client_login] = params[:log_client][:login] 
                redirect_to(:action => "index")
            else
                session[:client_id] = nil
                flash[:notice] = "Invalid client login/password combination"
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
      @project =  @current_client.projects.find( params[:project_id] )
      session[:year] = Time.now.year.to_s unless !session[:year].nil?
      session[:month] = Time.now.month.to_s unless !session[:month].nil?

      @activities = Activity.project_activities( @project.id, session[:month], session[:year] )
      
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
      render :layout => false 
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
    
end
