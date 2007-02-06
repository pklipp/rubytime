require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  fixtures :projects
  fixtures :users
  fixtures :roles

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session = { :user_id =>  1 }
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

    assert_not_nil assigns(:users)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:user)
    assert assigns(:user).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:user)
  end

  def test_create
    num_users = User.count

    post :create, :user => { :name => "New user", :login => "user1", :password => "abcabc", :email => "a@b.com", :role_id => 1 }

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_users + 1, User.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:user)
#    puts assigns(:user).inspect
    assert assigns(:user).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'
  end

  def test_confirm_destroy
    admin_id = 1
    user = User.find(admin_id)
    assert user.is_admin

    get :confirm_destroy, :id => admin_id

    assert_redirect :action => 'list'

    user_id = 2
    user = User.find(user_id)
    assert !user.is_admin

    get :confirm_destroy, :id => user_id

    assert_template 'confirm_destroy'
    assert assigns(:user)
  end

  def test_destroy
    admin_id = 1
    user_id = 2
    num_users = User.count 
   
    admin = User.find(admin_id)
    assert_not_nil admin

    post :destroy, :id => admin_id, :name_confirmation => admin.name
    assert_response :redirect
    assert_redirected_to :action => 'list'

    #destroy of admin is not allowed
    assert_equal num_users, User.count

    user = User.find(user_id)
    assert_not_nil user
    activities = Activity.find(:all, :conditions => ["user_id = ?",user_id])
    assert activities.size > 0
 
    #destroy without confirmation is not allowed
    post :destroy, :id => user_id
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert_equal num_users, User.count

    #destroy with confirmation is allowed
    post :destroy, :id => user_id, :name_confirmation => user.name
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert User.count < num_users

    assert_raise(ActiveRecord::RecordNotFound) {
      User.find(user_id)
    }

    activities = Activity.find(:all, :conditions => ["user_id = ?",user_id])
    assert_equal 0,activities.size
    
  end

end
