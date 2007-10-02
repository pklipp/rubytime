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
    assert_equal "client1-name", clients(:first_client).name
    assert_equal 1, clients(:first_client).id
    assert_equal "client2-name", clients(:another_client).name
  end
  
  def test_find_active
    cs = Client.find_active
    cs.each{|c| assert !c.is_inactive}
  end
  
end
