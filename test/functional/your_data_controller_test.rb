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
    assert_template 'users/_no_permissions'
  end

  def test_new_activity
    get :new_activity

    assert_response :success
    assert_template 'new_activity'

    assert_not_nil assigns(:activity)
  end

  def test_create_activity
    num_activities = Activity.count

    post :create_activity, :activity => {:comments => "Some comment", :project_id => 1, :minutes => "1",
      'date(1i)' => '2001', 'date(2i)' => '02', 'date(3i)' => '03'}

    assert_response :redirect
    assert_redirected_to :action => 'activities_list'

    assert_equal num_activities + 1, Activity.count
  end

  def test_create_activity_doesnt_allow_duplicate_date
    num_activities = Activity.count
    post :create_activity, :activity => {:comments => "First", :project_id => 1, :minutes => '2',
      'date(1i)' => '2001', 'date(2i)' => '02', 'date(3i)' => '03'}
    post :create_activity, :activity => {:comments => "Second", :project_id => 1, :minutes => '3',
      'date(1i)' => '2001', 'date(2i)' => '02', 'date(3i)' => '03'}
    assert_response :success
    assert_template 'new_activity'
    assert_match /already have activity/i, flash[:warning]
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

  def test_edit_rss_feed
    get :edit_rss_feed
    assert_response :success
    assert_not_nil assigns(:feed)
    assert_equal assigns(:feed), RssFeed.find_by_owner_id_and_owner_type(users(:pm).id, "User")
    assert_template "edit_rss_feed"
  end

  def test_edit_rss_feed_feed_is_created_on_demand
    login_as :admin2
    get :edit_rss_feed
    assert_response :success
    assert_not_nil assigns(:feed)
    assert_equal assigns(:feed), RssFeed.find_by_owner_id_and_owner_type(users(:admin2).id, "User")
  end

  def test_edit_rss_feed_not_manager
    login_as :dev
    get :edit_rss_feed
    assert_response :success
    assert_template 'users/_no_permissions'
  end

  def test_update_rss_feed
    post :update_rss_feed, :authentication => 'key', :user_4 => 1, :user_7 => 1, :role_3 => 1, :project_3 => 1, :project_4 => 1, :project_5 => 1
    feed = users(:pm).rss_feed
    assert_equal 'key', feed.authentication
    assert_equal '1234512345', feed.secret_key
    assert_redirected_to :action => 'edit_rss_feed'
    assert_equal [3, 4, 5], feed.elements.projects.sort
    assert_equal [4, 7], feed.elements.users.sort
    assert_equal [3], feed.elements.roles
  end

  def test_update_rss_feed_http
    post :update_rss_feed, :authentication => 'http'
    assert_equal 'http', users(:pm).rss_feed.authentication
    assert_redirected_to :action => 'edit_rss_feed'
  end

  def test_update_rss_feed_regenerate_key
    post :update_rss_feed, :authentication => 'key', :regenerate_key => '1'
    assert_equal 'key', users(:pm).rss_feed.authentication
    assert_not_equal '1234512345', users(:pm).rss_feed.secret_key
    assert_redirected_to :action => 'edit_rss_feed'
  end

  def test_rss_bad_id
    get :rss, :format => 'html', :id => 1024
    assert_response :success
    assert_match /not found/, @response.body
  end

  def test_rss_another_user
    login_as :admin2
    get :rss, :format => :html, :id => 1
    assert_response :success
    assert_match /denied/, @response.body
  end

  def test_rss_with_no_key
    get :rss, :format => :rss, :id => 1
    assert_response :success
    assert_match /denied/, @response.body
  end

  def test_rss_with_wrong_key
    get :rss, :format => :rss, :id => 1, :key => "idontknowthekey"
    assert_response :success
    assert_match /denied/, @response.body
  end

  def test_rss_with_correct_key
    get :rss, :format => :rss, :id => 1, :key => "1234512345"
    # TODO: the assertion below doesn't work, fix something...
    #assert_response :success
    assert_not_nil assigns(:days)
    assert_not_nil assigns(:pub_dates)
    assert_equal assigns(:days).keys.sort, assigns(:pub_dates).keys.sort

    # TODO: test the results
  end

# TODO: this doesn't work
#   def test_http_authorization
#     http_authorize(users(:pm).login, "admin")
#     get :rss, :format => :xml, :id => 2
#     assert_response :success
#   end

end
