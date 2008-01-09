class Notifier < ActionMailer::Base
    
  def remember_password(user)
    @subject    = '[RubyTime] Remember password'
    @body['user'] = user   
    @recipients = user.email
    @from       = MAIL_FROM
    @sent_on    = Time.now
  end
  
end
