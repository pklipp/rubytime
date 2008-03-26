require File.dirname(__FILE__) + '/../test_helper'
require 'application'

# Re-raise errors caught by the controller.
class ApplicationController; 
  def rescue_action(e) raise e end; 
end

class ApplicationControllerTest < Test::Unit::TestCase

  def setup
    @controller = ActivitiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :pm
  end

  def test_unset_calendar
    @request.env['HTTP_REFERER'] = '/'
    get :unset_calendar
    assert_nil session[:year]
    assert_nil session[:month]
  end

  def test_set_calendar
    @request.env['HTTP_REFERER'] = '/'
    get :set_calendar, :month => 2, :year => 2008
    assert_equal 2, session[:month].to_i
    assert_equal 2008, session[:year].to_i
  end

end
