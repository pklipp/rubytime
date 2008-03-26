require File.dirname(__FILE__) + '/../test_helper'

class RssFeedTest < ActiveSupport::TestCase

  fixtures :rss_feeds, :projects

  def test_generate_random_key
    feed = rss_feeds(:pmfeed)
    key = feed.secret_key
    feed.generate_random_key
    assert_not_nil feed.secret_key
    assert !feed.secret_key.blank?
    assert_not_equal key, feed.secret_key
  end

  def test_elements
    feed = rss_feeds(:pmfeed)
    assert_equal [1], feed.elements.projects
    assert_equal [3, 5], feed.elements.users.sort
    assert_equal [2], feed.elements.roles

    cfeed = rss_feeds(:clientfeed)
    assert_equal [3], cfeed.elements.projects
    assert cfeed.elements.roles.empty?
    assert cfeed.elements.users.empty?
    fp = projects(:first_project)
    assert_equal [2], cfeed.elements.users_in_project(fp)
    assert_equal [3], cfeed.elements.roles_in_project(fp)
  end

end
