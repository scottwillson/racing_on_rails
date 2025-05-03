# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: RacingAssociation.current.email, bcc: 'help@obra.org'
end
