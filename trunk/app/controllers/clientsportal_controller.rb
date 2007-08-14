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
        @client_name = Client.find_by_id(session[:client_id]).name
        render :action => "index"
    end

    #
    # Action is responsible for logging client. If successful then redirected    
    # to index action.
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
        begin
            @client = Client.find(session[:client_id])
        rescue
            flash[:notice] = "No such client"
            redirect_to :action => :index
        end

        render :action => "show_profile"
    end

    #
    # Showing logged client his/her projects.
    #
    def show_projects
        begin
            @client = Client.find(session[:client_id])
            @projects = @client.projects
        rescue
            flash[:notice] = "No such client"
            redirect_to :action => :index
        end

        render :action => "show_projects"
    end

    #
    # Showing client's selected project details. Client cannot see not his/her's
    # projects.
    #
    def show_project
        begin
            @project = Project.find(params[:id], :conditions => [ "client_id = (?)", session[:client_id]])
        rescue
            flash[:notice] = "No such project"
            redirect_to :action => "index"
        else
            @activities = Activity.find(:all, :conditions => [ "project_id = (?)", params[:id]])
        end
    end

    #
    # Showing client's seleted project activities. Client cannot see activities
    # of other client's projectes.
    #
    def show_project_activities
        begin
            @project =  Project.find(params[:project_id], :conditions => [ "client_id = (?)", session[:client_id]])
        rescue
            flash[:notice] = "No such project"
            redirect_to :action => "index"
        end

        session[:year] = Time.now.year.to_s unless !session[:year].nil?
        session[:month] = Time.now.month.to_s unless !session[:month].nil?

        @query = "SELECT "\
        + " ac.id, minutes, date, comments, user_id, role_id, invoice_id " \
        + "FROM activities ac " \
        + "LEFT JOIN users us ON (ac.user_id=us.id)" \
        + "LEFT JOIN roles ro ON (us.role_id=ro.id)" \
        + "WHERE project_id = '" + params[:project_id] + "' " \
        + " AND #{SqlFunction.get_year('date')}='" + session[:year] + "' " \
        + " AND #{SqlFunction.get_month_equation('date', session[:month])} " \
        + "ORDER BY date"

        @activities = Activity.find_by_sql @query
    end

    #
    # Showing details of selected activity.
    #
    def show_activity
        begin
            @activity = Activity.find(params[:id])
        rescue
            flash[:notice] = "No such activity"
            redirect_to :action => :index
        end
    end

    #
    # Showing client ISSUED ONLY invoices.
    #
    def show_invoices
        @invoices = Invoice.find(:all, :conditions => ["client_id = ?", session[:client_id]])
        render :action => "show_invoices"
    end

    #
    # Showing details of selected invoice.
    #
    def show_invoice
        begin
            @invoice = Invoice.find(params[:id], :conditions => ["client_id = ?", session[:client_id]])
        rescue
            flash[:notice] = "No such invoice"
            redirect_to :action => :index
        end
    end

    #
    # Showing fields for changing client's password.
    #
    def edit_client_password
        begin
            @clients_login = ClientsLogin.find(:first, :conditions => [ "login= ?", session[:client_login]])
            @clients_login.password=nil
            @clients_login.password_confirmation=nil
        rescue
            flash[:notice] = "No such client"
            redirect_to :action => :index
        end
    end

    #
    # Updates client password if everything is OK and redirecting to show_profile.    
    #
    def update_client_password
        @current_client = ClientsLogin.find(:first, :conditions => [ "login= ?", session[:client_login]])
        old_pass = Digest::SHA1.hexdigest(params[:old_password])
        if (old_pass == @current_client.password)
            @client = @current_client
            @client.password = params[:clients_login][:password]
            @client.password_confirmation = params[:clients_login][:password_confirmation]
            if (@client.valid?)
                new_pass = Digest::SHA1.hexdigest(params[:clients_login][:password])
                if @current_client.update_attributes(:password => new_pass, :password_confirmation => new_pass)
                    flash[:notice] = 'Individual password has been successfully updated'
                    redirect_to :action => 'show_profile'
                else
                    flash[:notice] = 'Updating error'
                    @client.password = nil
                    @client.password_confirmation = nil
                    redirect_to :action => 'edit_client_password'
                end
            else
                flash[:error] = "Password doesn't match"
                @client.password = nil
                @client.password_confirmation = nil
                redirect_to :action => 'edit_client_password'
            end
        else
            flash[:error] = "Current password is typed incorrectly or new password doesn't match with confirmation" 
            @client = @current_client
            @client.password = nil
            @client.password_confirmation = nil
            redirect_to :action => 'edit_client_password'
        end
    end

end
