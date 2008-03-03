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
    ActionMailer::Base.deliveries = []
  end

  def test_login_get
    get :login
    assert_response :success
    assert_template 'login'
  end

  def test_login_good
    pm = users(:pm)
    post(:login, {:log_user => {:login => pm.login, :password => "admin"}})
    assert_response :redirect
    assert_redirected_to :controller => "your_data"
    assert_not_nil session[:user_id]
    assert_equal pm.id, session[:user_id]
  end

  def test_login_bad
    post(:login, :log_user => {:login=> "wrong_login1111", :password => "wrong password"})
    assert_response :success
    assert_template "login"
    assert_not_nil flash[:error]
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
    assert_tag :tag => "form" , :content => /Enter e-mail/
  end

  def test_forgot_password_bad_email
    post :forgot_password, :forgot_pass => {:email => "nosuchemail@a.com"}
    assert_not_nil flash[:notice]
    assert_redirected_to :action => "login"
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  def test_forgot_password_good_email
    pm = users(:pm)
    pm.password_code = 'old'
    post :forgot_password, :forgot_pass => {:email => pm.email}
    pm.reload
    assert_not_equal 'old', pm.password_code
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not_nil flash[:notice]
    assert_redirected_to :action => "login"
  end

  def test_change_password_get_with_bad_code
    get :change_password, :code => "4-8-15-16-23-42"
    assert_redirected_to :action => "login"
  end

  def test_change_password_get
    pm = users(:pm)
    post :forgot_password, :forgot_pass => {:email => pm.email}
    pm.reload
    get :change_password, :code => pm.password_code
    assert_response :success
    assert_template 'change_password'
  end

  def test_change_password_post_passwords_not_matching
    pm = users(:pm)
    post :forgot_password, :forgot_pass => {:email => pm.email}
    pm.reload
    post :change_password, :code => pm.password_code, :user => {:password => "passone", :password2 => "passtwo"}
    assert_not_nil flash[:notice]
    assert_redirected_to :action => "change_password", :code => pm.password_code
  end

  def test_change_password_post_short_password
    pm = users(:pm)
    post :forgot_password, :forgot_pass => {:email => pm.email}
    pm.reload
    post :change_password, :code => pm.password_code, :user => {:password => "pass", :password2 => "pass"}
    assert_not_nil flash[:notice]
    assert_redirected_to :action => "change_password", :code => pm.password_code
  end

  def test_change_password_post
    pm = users(:pm)
    new_password = 'passwd'
    post :forgot_password, :forgot_pass => {:email => pm.email}
    pm.reload
    post :change_password, :code => pm.password_code, :user => {:password => new_password, :password2 => new_password}
    old_salt = pm.salt
    pm.reload
    assert_not_equal old_salt, pm.salt
    assert_not_nil User.authorize(pm.login, new_password)
    assert_not_nil flash[:notice]
    assert_redirected_to :action => "login"
  end
end
