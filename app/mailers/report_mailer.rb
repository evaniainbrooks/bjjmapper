class ReportMailer < ActionMailer::Base
  DEFAULT_TO = "evan@bjjmapper.com"
  DEFAULT_FROM = "no-reply@bjjmapper.com"

  default from: DEFAULT_FROM
  default to: DEFAULT_TO

  def report_email(params)
    @user = params.fetch(:user, nil)
    @subject = "#{params[:reason]} report from #{params[:email]}"
    @message = [params[:subject], params[:reason], params[:description], params[:email], @user.try(:id)].join("\r\n")
    mail(from: DEFAULT_FROM, to: DEFAULT_TO, subject: @subject, content_type: 'text/html', body: @message)
  end
end
