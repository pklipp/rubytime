require File.dirname(__FILE__) + '/../test_helper'
require 'clientsportal_controller'

# ----------------------------------------------------------------------------
# Functional tests of clientsportal controller.
#
# author: Wiktor Gworek
# ----------------------------------------------------------------------------


# Re-raise errors caught by the controller.
class ClientsportalController;
  def rescue_action(e)
    raise e
  end;
end

class ClientsportalControllerTest < Test::Unit::TestCase
  fixtures :clients, :projects, :invoices, :users, :activities, :clients_logins, :roles

  def setup
    @controller = ClientsportalController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new    
  end
  
  def test_login
    get :index    
    assert_redirected_to :controller => "clientsportal", :action => "login"
    assert_equal "Please log in", flash[:notice]
    
    get :show_profile
    assert_redirected_to :controller => "clientsportal", :action => "login"
    assert_equal "Please log in", flash[:notice]
  end
  
  def test_login_with_invalid_client
    post :login, {:log_client => {:login => "wrongclient", :password => "wrongpassword"}}
    assert_response :success
    assert_equal "Invalid client login/password combination", flash[:notice]
  end
  
  def test_login_with_inactive_client
    post :login, {:log_client => {:login => "client3", :password => "pass-client3"}}
    follow_redirect
    assert_response :success
    assert_tag :tag => "div", :attributes => {:id => "errorNotice"}, :content => /Your account is not active. Please contact to administrator./
  end
  
  def test_index_with_valid_client
    login_as_client
    get :index
    assert_response :success
    assert_template 'index'
    assert_tag :tag => "b", :ancestor => {:tag => "div", :attributes => { :id => "content"}}, :content => "client1"
  end 

  def test_show_profile
    login_as_client
    get :show_profile
    assert_response :success
    assert_template 'show_profile'
    assert_not_nil assigns(:client)  
    assert_tag :tag => "p", :content => /Client nr 1/, :ancestor => {:tag => "fieldset"}
    assert_tag :tag => "p", :content => /client1/, :descendant => {:tag => "b", :content => /Name:/}
  end
  
  def test_show_projects
    _test_show_projects "client1", "pass-client1", 5
    _test_show_projects "client2", "pass-client2", 1
  end
  
  def test_show_invoices
    _test_show_invoices "client1", "pass-client1", 2
    _test_show_invoices "client2", "pass-client2", 0
  end
  
  def test_logout
    login_as_client
    get :logout
    assert_redirected_to :controller => "clientsportal", :action => "login"
    assert_equal "Client logged out", flash[:notice]
    test_login
  end
  
#  def test_change_pass_valid
#    login_as_client
#    get :edit_client_password
#    assert_response :success
#    assert_template "edit_client_password"
#    post :update_client_password, :old_password => "pass-client1", :client => {:password => "newpass", :password_confirmation => "newpass"}
#    assert_redirected_to :controller => "clientsportal", :action => "show_profile"
#    assert_equal "Profile has been successfully updated", flash[:notice]
#    client = clients(:first_client)
#    assert_equal Digest::SHA1.hexdigest("newpass"), client.password
#  end
  
#  def test_change_pass_invalid
#    login_as_client
#    post :update_client_password, :old_password => "wrongpass", :client => {:password => "newpass", :password_confirmation => "newpass"}
#    assert_redirected_to :action => "edit_client_password"
#    assert_equal "Current password is typed incorrectly or new password doesn't match with confirmation", flash[:error]
#    
#    post :update_client_password, :old_password => "pass-client1", :client => {:password => "new22pass", :password_confirmation => "newpass123"}
#    assert_redirected_to :action => "edit_client_password"
#    assert_equal "Password doesn't match", flash[:error]
#  end
  
  def test_show_project_invalid
    login_as_client
    get :show_project, :id => 6
    assert_redirected_to :action => "index"
    assert_equal "No such project", flash[:notice]
  end
  
  def test_show_project_valid
    login_as_client
    get :show_project, :id => 5
    assert_template "show_project"
    project = assigns(:project)
    assert_equal "CoolProject3", project.name
    assert_equal "Desc of CoolProject3", project.description
  end
  
  def test_show_project_activities_invalid
    login_as_client
    get :show_project_activities, :project_id => 6
    assert_redirected_to :action => "index"
    assert_equal "No such project", flash[:notice]
  end
  
  def test_show_project_activities_valid
    login_as_client    
    get :show_project_activities, :project_id => 1, :session_year => Time.now.year.to_s, :session_month => Time.now.month.to_s 
    assert_equal session[:year], Time.now.year.to_s
    assert_equal session[:month], Time.now.month.to_s
    assert_response :success
    assert_template "show_project_activities"
    assert_not_nil assigns(:project)
    assert assigns(:project).valid?
    assert_not_nil assigns(:activities)
    assert_equal assigns(:project).activities.size, 8    
  end

  #TODO
  
 def test_show_activity_data
    login_as_client
    get :show_activity_data,:id => 1
    assert_response :success
    assert_template 'show_activity_data' 
    assert_tag :tag => "legend", :content => /Activity/, :ancestor => {:tag => "fieldset"}
    assert_tag :tag => "p", :content => /Comments/, :ancestor => {:tag => "fieldset"}
    assert_tag :tag => "p", :content => /Date:/, :ancestor => {:tag => "fieldset"}
    assert_tag :tag => "p", :content => /Hours:/, :ancestor => {:tag => "fieldset"}
    assert_tag :tag => "p", :content => /Invoiced:/, :ancestor => {:tag => "fieldset"}
  end
  
  
  def test_show_activities
    login_as_client
    get :show_activities
    assert_response :success  
    assert_tag :tag => "legend", :content => /Your activities:/, :ancestor => {:tag => "fieldset"}
  end
  
  def test_time_period
    login_as_client
    get :time_period, :id => 1
    assert_tag :tag => "legend", :content => /Time period:/, :ancestor => {:tag => "fieldset"}
    assert_tag :tag => "p", :content => /From:/
    assert_tag :tag => "p", :content => /To:/
    assert_tag :tag => 'input'  , :ancestor => {:tag => "form"}
  end
  
  def edit_client_password
    login_as_client
    get :show_profile
    assert_tag :tag => "div", :attributes => {:id => "fieldsets"}
    get :edit_client_password
    assert_tag :tag => "legned", :content => /Change your individual password/, :ancestor => {:tag => "fieldset"}
    assert_tag :tag => "input",:ancestor => {:tag => "form"}
  end
  
  def test_show_invoice
    login_as_client
    get :show_invoice, :id => 666
    assert_redirected_to :action => :index
  end
  
  
  
  
  # 
  # private methods
  #
  
  private
  
  def _test_show_projects(login, pass, number_of_projects)
    login_as_client(login, pass)
    get :show_projects
    assert_response :success
    assert_template 'show_projects'
    assert_not_nil :projects    
    assert_tag :tag => "table", :attributes => {:class => "standard"}, :children => {:count => number_of_projects + 1, :only => {:tag => "tr"}}
    assert_not_nil :client
  end    
  
  def _test_show_invoices(login, pass, number_of_invoices)
    login_as_client(login, pass)
    get :show_invoices
    assert_response :success
    assert_template 'show_invoices'
    assert_not_nil :invoices
    assert_tag :tag => "table", :attributes => {:class => "standard"}, :children => {:count => number_of_invoices + 1, :only => {:tag => "tr"}}
  end      

  
  
  
  
end
