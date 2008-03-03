require File.dirname(__FILE__) + '/../test_helper'
require 'activities_controller'

# Re-raise errors caught by the controller.
class ActivitiesController; 
  def rescue_action(e) raise e end; 
end

class ActivitiesControllerTest < Test::Unit::TestCase
  fixtures :activities, :users, :projects, :roles, :clients

  def setup
    @controller = ActivitiesController.new
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
    assert_not_nil assigns(:activities)
    assert_equal 10, assigns(:activities).length
    
    #chronological order
    assert descending?(assigns(:activities), :date) 
    
    #with session conditions
    @request.session[:year] = 2006.to_s
    @request.session[:month] = 8.to_s
    get :list
    assert_not_nil assigns(:activities)
    assert_equal Activity.count(:conditions => "#{SqlFunction.get_month_equation('date', 8)}  AND #{SqlFunction.get_year('date')} = '2006'"), assigns(:activities).size

    assert descending?(assigns(:activities), :date) 
  end

  def test_report
    post :search, { :commit => "Export to CSV" }
    assert_equal "text/csv; charset=utf-8; header=present", @response.headers["type"]
    lines = @response.body.split "\n"
    assert_equal Activity.count + 2, lines.size
    data = lines[1].split ","
    assert_equal 5, data.size
    activity = activities(:latest_activity)
    assert_equal data[0], activity.project.name
    assert_equal data[1], activity.user.login
    assert_equal data[2], activity.user.role.name
    assert_equal data[3], activity.date.to_s
    assert_equal data[4], activity.minutes.to_s

    # check details flag
    post :search, { :commit => "Export to CSV" , :search=> {:details => "1"} }
    assert_response :success
    assert_equal "text/csv; charset=utf-8; header=present", @response.headers["type"]
    lines = @response.body.split "\n"
    assert_equal Activity.count + 2, lines.size
    data = lines[1].split ","
    assert_equal 6, data.size
    assert_equal data[5], activity.comments.to_s
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:activity)
    assert assigns(:activity).valid?
  end

  
  
#  def test_edit
#    get :edit, :id => 1
#
#    assert_response :success
#    assert_template 'edit'
#
#    assert_not_nil assigns(:activity)
#    assert assigns(:activity).valid?
#  end
#
#  def test_update
#    post :update, :id => 1, :activity => {:minutes => "1", :project_id => 1, :comments => "comment", }
#    assert_response :redirect
#    assert_redirected_to :action => 'show', :id => 1
#  end

  def test_destroy
    assert_not_nil Activity.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    #remove is not allowed
    assert_not_nil Activity.find(1)
  end
end
