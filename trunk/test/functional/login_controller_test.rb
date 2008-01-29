require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

# Re-raise errors caught by the controller.
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase
  fixtures :users, :roles

  def setup
    @controller = LoginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_login
    pm = users(:pm)
    post(:login, {:log_user => {:login=> pm.login, :password => "admin"}})
    assert_response :redirect
    assert_redirected_to :controller =>  "your_data"
    assert_not_nil session[:user_id]

    post(:login, :log_user => {:login=> "wrong_login1111", :password => "wrong password"})
    assert_response :success
    assert_template "login"
    assert_not_nil flash[:notice]
    assert_nil session[:user_id]

  end
  
  def test_logout
    login_as :pm
    assert_not_nil session[:user_id]
    get :logout
    assert_response :redirect
    assert_redirected_to :action => "login"
    assert_nil session[:user_id]
  end
  
  def test_change_your_mail
    get :login
    assert_tag :tag => "form" , :content => / Enter e-mail/
  end
  
  
  
end
