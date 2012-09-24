class PostsController < ApplicationController
  def index
    flash.clear
    @subject = params[:subject].try(:strip)
    @mailing_list = MailingList.find(params[:mailing_list_id])
    
    if params[:month] && params[:year]
      begin
        date = Time.zone.local(params[:year].to_i, params[:month].to_i)
        @start_date = date.beginning_of_month
        @end_date = date.end_of_month
      rescue
        logger.debug "Could not parse date year: #{params[:year]} month: #{params[:month]}"
      end
    end

    if @start_date && @end_date
      @posts = @mailing_list.posts.where("date between ? and ?", @start_date, @end_date).paginate(:page => params[:page]).order("date desc")
    else
      @posts = @mailing_list.posts.paginate(:page => params[:page]).order("date desc")
    end
    
    if @subject.present?
      if @subject.size >= 4
        @posts = @posts.joins(:post_text).where("match(text) against (?)", @subject)
      else
        @posts = []
        flash[:notice] = "Search text must be at least four letters"
      end
    end
    
    @first_post_at = Post.minimum(:date)

    respond_to do |format|
      format.html
      format.rss do
        redirect_to mailing_list_posts_path(@mailing_list, :format => :atom), :status => :moved_permanently
      end
      format.atom
    end

    @first_post_at = Post.minimum(:date)
  end
  
  def show
    expires_in 1.hour, :public => true
    @post = Post.find(params["id"])
  end
  
  # Send email to local mail program. Don't save to database. Use mailing list's
  # archiver to store posts. This strategy gives spam filters a change to reject
  # bogus posts.
  def create
    if params[:reply_to_id].present?
      post_private_reply
    else
      post_to_list
    end
  end
  
  def post_private_reply
    @reply_to = Post.find(params[:reply_to_id])
    @mailing_list = MailingList.find(params[:mailing_list_id])
    @post = @mailing_list.posts.build(params[:post])
    if @post.valid?
      private_reply_email = MailingListMailer.private_reply(@post, @reply_to.sender).deliver
      flash[:notice] = "Sent private reply '#{@post.subject}' to #{private_reply_email.to}"
      redirect_to mailing_list_confirm_private_reply_path(@mailing_list)
    else
      render(:action => "new", :reply_to_id => @reply_to.id)
    end
  end
  
  def post_to_list
    @post = Post.new(params[:post])
    @mailing_list = MailingList.find(params[:mailing_list_id])
    @post.mailing_list = @mailing_list
    if @post.valid?
      MailingListMailer.post(@post).deliver
      flash[:notice] = "Submitted new post: #{@post.subject}"
      redirect_to mailing_list_confirm_path(@mailing_list)
    else
      render(:action => "new")
    end
  end
  
  def new
    @mailing_list = MailingList.find(params[:mailing_list_id])
    @post = Post.new(:mailing_list => @mailing_list)
    if params[:reply_to_id].present?
      @reply_to = Post.find(params[:reply_to_id])
      @post.subject = "Re: #{@reply_to.subject}"
    end
  end
end