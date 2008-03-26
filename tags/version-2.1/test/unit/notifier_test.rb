require File.dirname(__FILE__) + '/../test_helper'

class NotifierTest < ActionMailer::TestCase
  tests Notifier
  
  def test_forgot_password
    user = User.new(:name => "John Smith", :email => "js@example.com", :password_code => "5QGy3aq3N6MfgyZc")
    response = Notifier.create_forgot_password(user)
    assert_equal "[RubyTime] Remember password",response.subject
    assert_equal "js@example.com",response.to[0]
    assert_match(/Dear John Smith/,response.body)  
  end
end
