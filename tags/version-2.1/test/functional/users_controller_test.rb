require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  fixtures :projects, :users, :roles, :activities

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :pm

    @admin_id = 1
    @user_id = 2
    @num_users = User.count 
    @admin = User.find(@admin_id)
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
    assert assigns(:user).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'
  end

  def test_update_doesnt_deactivate_current_user
    post :update, :id => 1, :is_inactive => true
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert !User.find(1).is_inactive?
  end

  def test_confirm_destroy
    admin_id = 1
    user = User.find(admin_id)
    assert user.is_admin?

    get :confirm_destroy, :id => admin_id

    assert_response :redirect
    follow_redirect
    assert_template 'list'
    #assert_redirect :action => 'list'

    user_id = 2
    user = User.find(user_id)
    assert !user.is_admin?

    get :confirm_destroy, :id => user_id

    assert_template 'confirm_destroy'
    assert assigns(:user)
  end

  def test_destroy_doesnt_delete_current_user
    assert_not_nil @admin

    post :destroy, :id => @admin_id, :name_confirmation => @admin.name
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert_equal @num_users, User.count
    assert_nothing_raised {User.find(@admin_id)}
  end

  def test_destroy_doesnt_delete_admin
    admin2 = users(:admin2)
    assert_not_nil admin2

    post :destroy, :id => admin2.id, :name_confirmation => admin2.name
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert_equal @num_users, User.count
    assert_nothing_raised {User.find(admin2.id)}
  end

  def test_destroy_doesnt_delete_without_confirmation
    user = User.find(@user_id)
    assert_not_nil user
 
    post :destroy, :id => @user_id
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert_equal @num_users, User.count
    assert_nothing_raised {User.find(@user_id)}
  end

  def test_destroy_deletes_with_confirmation
    user = User.find(@user_id)
    assert_not_nil user

    post :destroy, :id => @user_id, :name_confirmation => user.name
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert_equal @num_users - 1, User.count

    assert_raise(ActiveRecord::RecordNotFound) {User.find(@user_id)}

    activities = Activity.find(:all, :conditions => ["user_id = ?", @user_id])
    assert_equal 0, activities.size
  end

  def test_update_password_updates_with_confirmation
    post :update_password, :id => 1, :user => {:password => 'alpha', :password_confirmation => 'alpha'}
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert User.find(1).password_equals?("alpha")
    assert_match /successful/, flash[:notice]
  end

  def test_update_password_doesnt_update_without_confirmation
    post :update_password, :id => 1, :user => {:password => 'alpha', :password_confirmation => 'beta'}
    assert_response :success
    assert_template 'edit_password'
    assert User.find(1).password_equals?("admin")
  end

end
