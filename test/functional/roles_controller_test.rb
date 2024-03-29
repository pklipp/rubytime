require File.dirname(__FILE__) + '/../test_helper'
require 'roles_controller'

# Re-raise errors caught by the controller.
class RolesController; def rescue_action(e) raise e end; end

class RolesControllerTest < Test::Unit::TestCase
  fixtures :roles, :users

  def setup
    @controller = RolesController.new
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

    assert_not_nil assigns(:roles)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:role)
    assert assigns(:role).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:role)
  end

  def test_create
    num_roles = Role.count

    post :create, :role => {:name => "Test role", :short_name => "TR" }

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_roles + 1, Role.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:role)
    assert assigns(:role).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy_doesnt_delete_role_with_users
    roles_count = Role.count
    assert_nothing_raised {Role.find(1)}

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal roles_count, Role.count
    assert_nothing_raised {Role.find(1)}
  end

  def test_destroy_doesnt_delete_role_without_confirmation
    roles_count = Role.count
    assert_nothing_raised {Role.find(3)}

    post :destroy, :id => 3
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal roles_count, Role.count
    assert_nothing_raised {Role.find(3)}
  end

  def test_destroy_deletes_role_without_users
    roles_count = Role.count
    assert_nothing_raised {Role.find(3)}

    post :destroy, :id => 3, :name_confirmation => "Accountant"
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal roles_count - 1, Role.count
    assert_raise(ActiveRecord::RecordNotFound) {Role.find(3)}
  end
end
