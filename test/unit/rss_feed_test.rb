require File.dirname(__FILE__) + '/../test_helper'

class RssFeedTest < ActiveSupport::TestCase

  fixtures :rss_feeds

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
    assert [1], feed.elements.projects
    assert [3, 5], feed.elements.users.sort
    assert [2], feed.elements.roles
  end

end
