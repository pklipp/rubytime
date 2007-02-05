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
    @controller = ActivitiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user_id] = 1
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
    
    @activities = assigns(:activities)
    
    assert_equal 3, @activities.length
    
    #chronological order
    assert @activities[0].date >= @activities[1].date
    assert @activities[1].date >= @activities[2].date
    
#    puts @activities[0].date
#    puts @activities[1].date
#    puts @activities[2].date

    
    #with session conditions
    @request.session[:month] = 8.to_s
    
    get :list
    
    assert_not_nil assigns(:activities)
    
    @activities = assigns(:activities)
    
    assert_equal 3, @activities.length
    
#    puts @activities[0].date
#    puts @activities[1].date
#    puts @activities[2].date

    #chronological order
    assert @activities[0].date >= @activities[1].date, "not chronological order"
    assert @activities[1].date >= @activities[2].date, "not chronological order"

  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:activity)
    assert assigns(:activity).valid?
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:activity)
    assert assigns(:activity).valid?
  end

  def test_update
    post :update, :id => 1, :activity => {:minutes => "1", :project_id => 1, :comments => "comment", }
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
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
