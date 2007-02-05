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
end
