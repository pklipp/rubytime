require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @user = User.find :first
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

  def test_email_formats
    good = ["jozek@onet.pl", "jan.kowalski@gmail.com", "george_w_bush@whitehouse.gov", "a.b.c@mail.test-site.test-domain.pl", "ME@MYSERVER.ORG"]
    bad = ["jozek@onet.p", "@home", "root@localhost", "test", "tooshort@pl", "user@test_site.pl", "one@two@three"]
    good.each {|email| assert check_email_format(email), "Email address #{email} should be accepted"}
    bad.each {|email| assert !check_email_format(email), "Email address #{email} should not be accepted"}
  end

  def test_hashed_pass
    assert_equal "a7faba4b6f65e5ed718914e6cfa701becc402a55", User.hashed_pass("mypassword", "12345")
  end

  def test_create_new_salt_should_be_random
    s1 = User.create_new_salt
    s2 = User.create_new_salt
    assert_not_equal s1, s2
  end

  def test_find_active
    assert_equal %w(admin bob fox john admin2), User.find_active.collect(&:login)
  end

  def test_password_equals
    @user.salt = User.create_new_salt
    @user.password = "boss"
    assert @user.password_equals?("boss")
  end

  def test_search
    found = User.search("l")
    assert_equal 2, found.size
    assert found.include?(users(:bob))
    assert found.include?(users(:pm))
  end

  private

  def check_email_format(email)
    @user.email = email
    @user.valid?
  end

end
