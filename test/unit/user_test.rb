require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @user = User.find :first
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of User,  @user
  end

  def test_authorize
    assert_nil User.authorize("", "")
    assert_nil User.authorize("wrong!!", "wrong")
    assert_kind_of User, User.authorize("admin", "admin")
    assert_kind_of User, User.authorize("fox", "dev")
    
    
#    u = User.find :first, :conditions => ["is_inactive = ? ", false]
#    assert_kind_of User, u
#    user = User.authorize(u.login, u.password)
#    assert_kind_of User, user
#    assert_equal u.id, user.id
  end
end
