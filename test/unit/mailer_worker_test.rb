require File.join(File.dirname(__FILE__) + "/../bdrb_test_helper")
require File.dirname(__FILE__) + '/../test_helper'
require "workers/mailer_worker"

class MailerWorkerTest < ActiveSupport::TestCase
  def test_send
    mailer_worker = MailerWorker.new
    params = { :email => { :subject => "Dogs at Bike Races" },
                           :from => "me@obra.org",
                           :body => "Canines are a problem, though not as much as cats."
             }
    mailer_worker.email_members(params)
  end
end
