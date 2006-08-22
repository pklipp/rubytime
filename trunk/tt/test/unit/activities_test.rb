require File.dirname(__FILE__) + '/../test_helper'

class ActivitiesTest < Test::Unit::TestCase
  fixtures :activity

  def setup
    @activities = Activities.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Activities,  @activities
  end
end
