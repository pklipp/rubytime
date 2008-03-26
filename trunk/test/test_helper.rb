ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def login(email = "admin", password = "admin" )
    old_controller = @controller
    @controller = LoginController.new
    post(
      :login,
      {:log_user => {:login => email, :password => password}}
    )
    @controller = old_controller 
  end
  
  def login_as(user = "admin", password="admin" )
    case user
      when String then login(user, password)
      when :pm then login(users(:pm).login, "admin")
      when :dev then login(users(:dev).login, "dev")
      when :admin2 then login(users(:admin2).login, "zxczxczxc")
      else raise "No user defined: #{user}"
    end
  end
  
  # helper to login as client
  def login_as_client(login_ = "client1", password_ = "pass-client1") 
    post :login, {:log_client => {:login => login_, :password => password_}}
    assert_redirected_to :action => "index"
    assert_not_nil session[:client_id]
    client = ClientsLogin.find(:first, :conditions => [ "login= ?", session[:client_login]])
    assert_equal login_, client.login
  end
  
  def ascending?(array, object_method)
    1.upto(array.size-1) { |i| return false unless array[i].send(object_method) >= array[i-1].send(object_method)  }
  end
  
  def descending?(array, object_method)
    1.upto(array.size-1) { |i| return false unless array[i].send(object_method) <= array[i-1].send(object_method) }
  end

  def http_authorize(login, pass)
    @request.env["HTTP_AUTHORIZATION"] = "Basic #{Base64.encode64("#{login}:#{pass}")}"
  end

end
