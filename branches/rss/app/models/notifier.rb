class Notifier < ActionMailer::Base
      
  def forgot_password(user)
    @recipients = user.email
    @from      = MAIL_FROM
    @subject   = "[RubyTime] Remember password"
    @sent_on   = Time.now 
    @body['user'] = user 
    @body['link'] =  url_for(:host => SERVER_URL ,:controller => "login", :action => "change_password" , :code => user.password_code )
  end
  
  
end
