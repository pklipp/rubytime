require File.dirname(__FILE__) + '/../test_helper'

class ClientTest < Test::Unit::TestCase
  fixtures :clients

  def setup
    @client = Client.find :first
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Client,  @client
  end
  
  def test_clients_count
    assert_equal 3, Client.count
  end
  
  def test_client_content
    assert_equal "client1", clients(:first_client).name
    assert_equal 1, clients(:first_client).id
    assert_equal "client2", clients(:another_client).login
    assert_equal "client2", clients(:another_client).name
  end
  
  def test_authorize
    assert_nil Client.authorize("", "")
    assert_nil Client.authorize("wrong client!!", "wrong pass")
    assert_kind_of Client, Client.authorize("client1", "pass-client1")
    assert_kind_of Client, Client.authorize("client2", "pass-client2")
  end
end
