class Admin::EmailsController < ApplicationController
  before_filter :login_required
  layout 'admin/application'

  def new
    @email = Admin::MemberMailer.create_email
    @members_count = Racer.find_all_current_email_addresses.size
  end

  def confirm
    @email = Admin::MemberMailer.create_email
    @email.from = params[:email][:from]
    @email.subject = params[:email][:subject]
    @email.body = params[:email][:body] || ""
    @members_count = Racer.find_all_current_email_addresses.size
    if @email.from.blank? || @email.subject.blank? || @email.body.empty?
      flash[:warn] = "From, subject, and body are required"
      render :action => "new"
    else
      render :action => "confirm"
    end
  end

  # Down and dirty replacement of BackgrounDRb
  def create
	if Rails.env == "test"
	  Admin::MemberMailer.email_all(params[:email][:subject], params[:email][:from], params[:email][:body])
	else
	  Thread.new { Admin::MemberMailer.email_all(params[:email][:subject], params[:email][:from], params[:email][:body]) }
	end
    flash[:info] = "Sent email"
    redirect_to :action => :new
  end
end