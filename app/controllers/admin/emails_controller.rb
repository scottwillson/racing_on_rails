class Admin::EmailsController < ApplicationController
  def new
    @email = MemberMailer.create_email
  end
end