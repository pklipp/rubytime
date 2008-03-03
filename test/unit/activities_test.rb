require File.dirname(__FILE__) + '/../test_helper'

class ActivityTest < Test::Unit::TestCase
  fixtures :activities, :users

  def setup
    @activity = Activity.find :first
  end

  def test_convert_duration
    assert_equal 60, Activity.convert_duration("1:00")
    assert_equal 10, Activity.convert_duration("0:10")
    assert_equal 8*60, Activity.convert_duration("8")
    assert_equal 1.5*60, Activity.convert_duration("1.5")
    assert_equal nil, Activity.convert_duration("x")
    assert_equal nil, Activity.convert_duration("1m")
  end

  def test_viewable_by_admin
    admin = users(:pm)
    assert Activity.find(:all).all? {|act| act.viewable_by?(admin)}
  end

  def test_viewable_by_dev
    dev = users(:dev)
    assert_equal 3, Activity.find(:all).find_all {|act| act.viewable_by?(dev)}.size
  end

  def test_editable_by_admin
    admin = users(:pm)
    assert_equal 8, Activity.find(:all).find_all {|act| act.editable_by?(admin)}.size
  end

  def test_editable_by_dev
    dev = users(:dev)
    assert_equal 2, Activity.find(:all).find_all {|act| act.editable_by?(dev)}.size
  end

  def test_project_activities
    acts = Activity.project_activities(1, 8, 2006)
    assert_equal 4, acts.size
    acts.each do |a|
      assert_equal Activity, a.class
      assert_equal 2006, a.date.year
      assert_equal 8, a.date.month
    end
  end

end
