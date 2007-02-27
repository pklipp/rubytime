require File.dirname(__FILE__) + '/../test_helper'

class ActivityTest < Test::Unit::TestCase
  fixtures :activities

  def setup
    @activity = Activity.find(1)
    @activities = Activity.find((1..3).to_a)
  end

  #test activities ordering
  def test_order
    assert_equal 3, @activities.size 
  end
  
  def test_convert_duration
    assert_equal 60, Activity.convert_duration("1:00")
    assert_equal 10, Activity.convert_duration("0:10")
    assert_equal 8*60, Activity.convert_duration("8")
    assert_equal 1.5*60, Activity.convert_duration("1.5")
    assert_equal nil, Activity.convert_duration("x")
    assert_equal nil, Activity.convert_duration("1m")
  end
end
