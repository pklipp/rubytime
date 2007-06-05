require File.dirname(__FILE__) + '/../test_helper'
require 'clients_controller'

# Re-raise errors caught by the controller.
class ClientsController; def rescue_action(e) raise e end; end

class ClientsControllerTest < Test::Unit::TestCase
  fixtures :clients, :projects, :invoices, :users

  def setup
    @controller = ClientsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :pm
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:clients)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:client)
    assert_not_nil assigns(:projects)
    
    assert assigns(:client).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:client)
  end

  def test_create
    num_clients = Client.count

    post :create, :client => {:name => "new_project", :description => "New project"}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_clients + 1, Client.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:client)
    assert assigns(:client).valid?
  end
  
#  def test_change_pass 
#    get :edit, :id => 1
#    
#    assert_response :success
#    assert_template 'edit'
#    
#    post :update, :id => 1, :new_password => "new-client-pass"
#    assert_redirected_to :action => 'show', :id => 1
#    
#    assert assigns(:client)
#    assert_equal clients(:first_client).password, Digest::SHA1.hexdigest("new-client-pass")    
#  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_confirm_destroy  
    get :confirm_destroy, :id => 1

    assert_template 'confirm_destroy'
    assert assigns(:client)
  end

  def test_destroy
    client_id = 1
    client = Client.find(client_id)
    client_count = Client.count
    assert_not_nil client

    #dependent data
    projects = Project.find(:all, :conditions => ["client_id = ?", client_id])
    assert projects.size > 0
    
    activities_count = Activity.count
    client_activities_count = 0
    projects.each do |p|
      client_activities_count += p.activities.size 
    end
    assert client_activities_count > 0

    invoices = Invoice.find(:all, :conditions => ["client_id = ?",client_id])
    assert invoices.size > 0

    
    #destroy without confirmation is not allowed
    post :destroy, :id => client_id
    assert_response :redirect
    assert_redirected_to :action => 'list'
    
    assert_equal client_count, Client.count

    #destroy with confirmation is allowed
    post :destroy, :id => client_id, :name_confirmation => client.name
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Client.find(client_id)
    }

    #delete client's projects
    projects = Project.find(:all, :conditions => ["client_id = ?", client_id])
    assert_equal 0, projects.size

    #delete client's projects' activities
    assert_equal Activity.count + client_activities_count, activities_count

    #delete client's invoices
    invoices =  Invoice.find(:all, :conditions => ["client_id = ?",client_id])
    assert_equal 0, invoices.size

  end

  def test_destroy_all_and_add
    clients = Client.find(:all)
    clients.each do |c|
      c.destroy
    end
  
    assert_equal 0, Client.count

    get :list
    assert_tag :tag => "a", :attributes => { :href => "/clients/new" }
  end
end
