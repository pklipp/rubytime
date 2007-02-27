require File.dirname(__FILE__) + '/../test_helper'

class TestHelperTest < Test::Unit::TestCase

  def setup
    
  end

  def test_ascending?
    assert ascending?([1,2,14,50], :to_i)
    assert ascending?([1,2,2,14,14,50], :to_i)
    assert !ascending?([1,14,13,50], :to_i)
    assert ascending?([1,1,1,1], :to_i)
    assert ascending?([1], :to_i)
  end

  def test_descending?
    assert descending?([50,14,2,1,-10], :to_i)
    assert descending?([1,1,0,-7,-12], :to_i)
    assert !descending?([50,14,2,3], :to_i)
    assert descending?([1,1,1,1], :to_i)
    assert descending?([1], :to_i)
  end

end
