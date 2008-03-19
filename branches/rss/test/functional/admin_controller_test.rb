require File.dirname(__FILE__) + '/../test_helper'
require 'admin_controller'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < Test::Unit::TestCase
  fixtures :users, :roles, :activities, :projects

  def setup
    @controller = AdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  #security check - admin controller accessible only for admins
  def test_authorization
    login_as :dev
    get :index
    assert_response :success
    assert_tag :content => /You have no permissions to view this page!/
  end

  def test_export_db
    login_as :pm
    get :export_db
    assert_response :success 
    assert_equal "text/plain; charset=utf-8; header=present", @response.headers["type"] 
  end

  def test_previous_day
    #current activities
    activity1 = activities(:yesterday_one)
    assert_valid activity1

    activity2 = activities(:yesterday_two)
    assert_valid activity2

    #old activity
    old_activity = activities(:old_activity)
    assert_valid old_activity

    login_as :pm

    get :previous_day
    assert_response :success
    assert_tag :tag => "legend", :content => /Activities List/
    assert_tag :tag => "td", :content => activity1.date.to_s
    assert_tag :tag => "td", :content => activity1.project.name
    assert_tag :tag => "td", :content => activity2.date.to_s
    assert_tag :tag => "td", :content => activity2.project.name
    assert_no_tag :tag => "td", :content => old_activity.date.to_s
  end
end
