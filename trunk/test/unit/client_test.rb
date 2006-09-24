require File.dirname(__FILE__) + '/../test_helper'

class ClientTest < Test::Unit::TestCase
  fixtures :clients

  def setup
    @client = Client.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Client,  @client
  end
end
