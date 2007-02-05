require File.dirname(__FILE__) + '/../test_helper'
require 'activities_controller'
require 'login_controller'

# Re-raise errors caught by the controller.
class ActivitiesController; 
  def rescue_action(e) raise e end; 
  
  #override autorization
  def authorize
  end
end

class ActivitiesControllerTest < Test::Unit::TestCase
  fixtures :activities, :users

  def setup
    @controller = YourDataController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user_id] = 1
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'activities_list'
  end

  def test_activities_list
    get :activities_list

    assert_response :success
    assert_template 'activities_list'

    assert_not_nil assigns(:activities)
    
    @activities = assigns(:activities)
    
    assert_equal 3, @activities.length
    
    #chronological order
    assert @activities[0].date < @activities[1].date
    assert @activities[1].date < @activities[2].date
    
    
    #with session conditions
    @request.session[:month] = 8.to_s
    
    get :activities_list
    
     assert_not_nil assigns(:activities)
    
    @activities = assigns(:activities)
    
    assert_equal 3, @activities.length
    
    #chronological order
    assert @activities[0].date < @activities[1].date
    assert @activities[1].date < @activities[2].date
  end

  def test_show_activity
    get :show_activity, :id => 1

    assert_response :success
    assert_template 'show_activity'

    assert_not_nil assigns(:activity)
    assert assigns(:activity).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new_activity'

    assert_not_nil assigns(:activity)
  end

  def test_create_activity
    num_activities = Activity.count

    post :create_activity, :activity => {}

    assert_response :redirect
    assert_redirected_to :action => 'activities_list'

    assert_equal num_activities + 1, Activity.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:activity)
    assert assigns(:activity).valid?
  end

  def test_update
    post :update_activity, :id => 1, :activity => {:minutes => "60:00"}
    assert_response :redirect
    assert_redirected_to :action => 'activities_list', :id => 1
  end

  def test_destroy
    assert_not_nil Activity.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    #remove is not allowed
    assert_not_nil Activity.find(1)
  end
end
