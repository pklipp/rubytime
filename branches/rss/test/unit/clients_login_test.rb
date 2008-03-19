require File.dirname(__FILE__) + '/../test_helper'

class ClientsLoginTest < Test::Unit::TestCase
  fixtures :clients_logins, :clients

  def setup
    @clients_login = clients_logins(:one_cl)
  end

  def test_authorize_good
    assert_equal clients(:another_client), ClientsLogin.authorize("client2", "pass-client2")
  end

  def test_authorize_bad
    assert_nil ClientsLogin.authorize("client1", "qweqwe")
  end

  def test_encrypt_password
    @clients_login.new_password = "newpass"
    @clients_login.encrypt_password
    assert_equal "6c55803d6f1d7a177a0db3eb4b343b0d50f9c111", @clients_login.password
  end

  def test_password_equals
    @clients_login.new_password = "somepassword"
    @clients_login.encrypt_password
    assert @clients_login.password_equals?("somepassword")
  end

end
