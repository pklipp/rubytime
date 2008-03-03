require File.dirname(__FILE__) + '/../test_helper'

class ClientTest < Test::Unit::TestCase
  fixtures :clients

  def setup
    @client = Client.find :first
  end

  def test_clients_count
    assert_equal 5, Client.count
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

  def test_search
    found = Client.search("name")
    assert_equal 3, found.size
    assert_equal [false] * 2 + [true], found.collect {|cl| cl.is_inactive?}
  end

  def test_search_2
    found = Client.search("ent")
    assert_equal 5, found.size
    assert_equal [false] * 3 + [true] * 2, found.collect {|cl| cl.is_inactive?}
  end

end
