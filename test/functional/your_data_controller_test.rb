require File.dirname(__FILE__) + '/../test_helper'
require 'your_data_controller'

# Re-raise errors caught by the controller.
class YourDataController; 
  def rescue_action(e) raise e end; 
end

class YourDataControllerTest < Test::Unit::TestCase
  fixtures :activities, :users, :projects, :clients, :roles

  def setup
    @controller = YourDataController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :pm
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
    assert_equal 6, assigns(:activities).length
    #chronological order
    assert descending?(assigns(:activities), :date), "Activities should be ascending"
    
    #with session conditions
    @request.session[:year] = 2006.to_s
    @request.session[:month] = 8.to_s
    get :activities_list
    assert_not_nil assigns(:activities)    
    assert_equal Activity.count(:conditions => "MONTH(date) = 8  AND YEAR(date) = 2006 AND user_id = #{assigns(:current_user).id}"), assigns(:activities).size
    #chronological order
    assert descending?(assigns(:activities), :date), "Activities should be ascending"
  end

  def test_show_activity
    get :show_activity, :id => 1

    assert_response :success
    assert_template 'show_activity'

    assert_not_nil assigns(:activity)
    assert assigns(:activity).valid?
  end

  def test_new_activity
    get :new_activity

    assert_response :success
    assert_template 'new_activity'

    assert_not_nil assigns(:activity)
  end

  def test_create_activity
    num_activities = Activity.count

    post :create_activity, :activity => {:comments => "Some comment", :project_id => 1, :minutes => "1", :date => Time.new }

    assert_response :redirect
    assert_redirected_to :action => 'activities_list'

    assert_equal num_activities + 1, Activity.count
  end

  def test_edit_activity
    get :edit_activity, :id => 1

    assert_response :success
    assert_template 'edit_activity'

    assert_not_nil assigns(:activity)
    assert assigns(:activity).valid?
  end

  def test_update_activity
    post :update_activity, :id => 1, :activity => {:minutes => "8:00"}
    assert_response :redirect
    assert_redirected_to :action => 'activities_list', :id => 1

    
    post :update_activity, :id => 1, :activity => {:minutes => "0"}
    assert_response :success
    assert_template "edit_activity"
    assert_not_nil flash[:notice]

  end

end
