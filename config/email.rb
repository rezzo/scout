# wraps the choice of email mechanism - can either be pony or postmark, depending on the config settings

require 'pony'
require 'postmark'
require 'mail'

module Email

  def self.deliver!(tag, to, subject, body)
    if email?
      if config[:email][:via] == :pony
        with_pony! tag, to, subject, body
      elsif config[:email][:via] == :postmark
        with_postmark! tag, to, subject, body
      else
        puts "[#{tag}][ERROR] No delivery method specified."
        false
      end
    else 
      sent_message "FAKE", tag, to, subject, body
      true
    end
    
  # Important that this method *not* raise any Exceptions, 
  # because our top-level generic exception handlers will 
  # cause an error report to get sent, leading to an infinite loop.

  rescue Exception => exc
    puts "EXCEPTION SENDING EMAIL:"
    puts "\n#{exc.class}"
    puts "\n#{exc.message}"
    if exc.backtrace and exc.backtrace.respond_to?(:each)
      exc.backtrace.each do |line|
        puts line
      end
    end
  end

  # send using a plain SMTP client
  def self.with_pony!(tag, to, subject, body)
    options = config[:email][:pony].dup
    options[:from] = config[:email][:from]
    options[:reply_to] = config[:email][:reply_to]

    begin
      Pony.mail options.merge(:subject => subject, :body => body, :to => to)
      sent_message "Pony", tag, to, subject, body
      true
    rescue Errno::ECONNREFUSED
      puts "\n[#{tag}][Pony] Couldn't email message, connection refused! Check email settings."
      false
    end
  end

  # send using the Postmark service
  def self.with_postmark!(tag, to, subject, body)
    message = Mail.new

    message.delivery_method Mail::Postmark, :api_key => config[:email][:postmark][:api_key]

    message.content_type = "text/plain"
    message.tag = tag

    message.from = config[:email][:from]
    message.reply_to = config[:email][:reply_to]

    message.to = to
    message.subject = subject
    message.body = body

    begin
      message.deliver!
      sent_message "Postmark", tag, to, subject, body
      true
    rescue Exception => e
      puts "\n[#{tag}][Postmark] Couldn't send message to Postmark. Trying Pony as a backup."

      # backup, try to use Pony to send the message
      if with_pony!(tag, to, subject, body)
        Admin.postmark_down tag, to, subject, body
        true
      else
        puts "\n[#{tag}][Pony] Nope, failed to send via Pony too. Oh well!"
        false
      end
    end
  end

  # always disable email in test mode
  # allow development mode to disable email by withholding the from email
  def self.email?
    !Sinatra::Application.test? and config[:email][:from].present?
  end

  def self.sent_message(method, tag, to, subject, body)
    return if Sinatra::Application.test?
    
    puts
    puts "--------------------------------"
    puts "[#{tag}][#{method}] Delivered to #{to}:"
    puts "\n= Subject: #{subject}"
    puts "\n#{body}"
    puts "--------------------------------"
    puts
  end

end