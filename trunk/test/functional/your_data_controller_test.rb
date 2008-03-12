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
    assert_template 'activities_calendar'
  end

  def test_activities_list
    get :activities_list
    assert_response :success
    assert_template 'activities_list'
    assert_not_nil assigns(:activities)
    assert_equal 7, assigns(:activities).length
    #chronological order
    assert descending?(assigns(:activities), :date), "Activities should be in descending order"
  end

  def test_activities_list_with_year_and_month
    #with session conditions
    @request.session[:year] = 2006.to_s
    @request.session[:month] = 8.to_s
    get :activities_list
    assert_not_nil assigns(:activities)  
    assert_equal Activity.count(:conditions => "#{SqlFunction.get_month_equation('date', 8)} AND #{SqlFunction.get_year('date')} = '2006' " +
      " AND user_id = #{users(:pm).id}"), assigns(:activities).size
    #chronological order
    assert descending?(assigns(:activities), :date), "Activities should be in descending order"
  end

  def test_activities_list_with_search_params
    get :activities_list, :search => {:date_from => "2000-01-01", :date_to => "2004-04-04", :user_id => 1}
    assert_not_nil assigns(:activities)
    assert_equal 2, assigns(:activities).size
    assert descending?(assigns(:activities), :date), "Activities should be in descending order"
  end

  def test_show_activity
    get :show_activity, :id => 1

    assert_response :success
    assert_template 'show_activity'

    assert_not_nil assigns(:activity)
    assert assigns(:activity).valid?
  end

  def test_show_activity_doesnt_show_other_users_activities
    login_as :dev
    get :show_activity, :id => 1

    assert_response :success
    assert_template '/users/_no_permissions'
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
