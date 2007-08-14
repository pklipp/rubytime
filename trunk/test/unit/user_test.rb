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
        
    u = User.authorize("fox", "dev")
    assert_kind_of User, u
    assert_equal u.login, "fox"
    assert_equal u.role.name, "Developer"
  end
  
end
