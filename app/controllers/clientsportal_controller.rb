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
    # Showing client's selected project details. Client cannot see not his/her's
    # projects.
    #
    def show_project
      @project = @current_client.projects.find( params[:id] )
      @activities = @project.activities
            
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "No such project"
      redirect_to :action => "index"
    end

    #
    # Showing calendar with project activities. Client cannot see activities
    # of other client's projectes.
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
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "No such activity"
      redirect_to :action => :index
    end

    #
    # Showing client ISSUED ONLY invoices.
    #
    def show_invoices
        @invoices = @current_client.invoices
        render :action => "show_invoices"
    end

    #
    # Showing details of selected invoice.
    #
    def show_invoice
      @invoice = @current_client.invoices.find( params[:id] )
    rescue
      flash[:notice] = "No such invoice"
      redirect_to :action => :index
    end

    #
    # Showing fields for changing client's password.
    #
    def edit_client_password
      @clients_login = @current_client.clients_logins.find_by_login( session[:client_login] )
      @clients_login.password = nil
      @clients_login.password_confirmation = nil
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
        
        # If passed wrong +old+ password - redirect back to edit form
        unless @client_login.password_equals? params[:old_password]
          flash[:error] = "Current password is typed incorrectly or new password doesn't match with confirmation"
          redirect_to :action => 'edit_client_password' and return  
        end

        @client_login.password = params[:clients_login][:password]
        @client_login.password_confirmation = params[:clients_login][:password_confirmation]

        # Check if updated client login record can be saved - redirect back to edit form if not
        unless @client_login.valid?
          flash[:error] = "Password doesn't match or some other error occured"
          @client_login.password, @client_login.password_confirmation = [nil,nil]
          redirect_to :action => 'edit_client_password' and return
        end

        # Should be secure to save it at this point
        @client_login.save!
        
        flash[:notice] = 'Individual password has been successfully updated'
        redirect_to :action => 'show_profile'
    end

end
