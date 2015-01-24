# Archive of Mailman mailing lists
class PostsController < ApplicationController
  # List all posts for :mailing_list_id
  # :subject: search for matching subjects. Limited to 4+ characters by MySQL full text search
  # Assigns:
  #  * @subject
  #  * @mailing_list
  #  * @posts: original Posts, paginted, most recent first
  def index
    flash.clear
    @subject = params[:subject].try(:strip)
    @mailing_list = MailingList.find(params[:mailing_list_id])

    respond_to do |format|
      format.html do
        if @subject.present?
          @posts = Post.matching(@mailing_list, @subject).page(page)
        else
          @posts = @mailing_list.posts.original.order("position desc").page(page)
        end
      end

      format.rss do
        redirect_to mailing_list_posts_path(@mailing_list, format: :atom), status: :moved_permanently
      end

      format.atom do
        @posts = @mailing_list.posts.original.order("position desc").limit(20)
      end
    end
  end

  # Show Post. If original, include replies.
  def show
    @post = Post.includes(:replies).includes(:original).includes(:mailing_list).where(id: params["id"]).first
    unless @post
      flash[:notice] = "Could not find post with ID #{params[:id]}"
      return redirect_to(mailing_lists_path)
    end
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

  # Sent as email through Postfix
  def post_private_reply
    @reply_to = Post.find(params[:reply_to_id])
    if @reply_to.from_email.blank?
      flash[:warn] = "Could not reply to post with no email address"
      return redirect_to(mailing_list_posts_path(@reply_to.mailing_list))
    end

    @mailing_list = MailingList.find(params[:mailing_list_id])
    @post = @mailing_list.posts.build(post_params)
    if @post.valid?
      begin
        private_reply_email = MailingListMailer.private_reply(@post, @reply_to.from_email).deliver_now
        flash[:notice] = "Sent private reply '#{@post.subject}' to #{private_reply_email.to}"
        redirect_to mailing_list_confirm_private_reply_path(@mailing_list)
      rescue ArgumentError, Net::SMTPSyntaxError, Net::SMTPServerBusy, Net::SMTPFatalError => e
        flash[:warn] = "Could not post: #{e}. Please retry, or email #{RacingAssociation.current.email} for help"
        render "new", reply_to_id: @reply_to.id
      end
    else
      render "new", reply_to_id: @reply_to.id
    end
  end

  # Sent as email to Mailman through Postfix
  def post_to_list
    @post = Post.new(post_params)
    @mailing_list = MailingList.find(params[:mailing_list_id])
    @post.mailing_list = @mailing_list
    if @post.valid?
      begin
        MailingListMailer.post(@post).deliver_now
        flash[:notice] = "Submitted new post: #{@post.subject}"
        redirect_to mailing_list_confirm_path(@mailing_list)
      rescue Net::SMTPSyntaxError, Net::SMTPServerBusy, Net::SMTPFatalError => e
        flash[:warn] = "Could not post: #{e}. Please retry, or email #{RacingAssociation.current.email} for help"
        render "new"
      end
    else
      render "new"
    end
  end

  # Create new mailing list post
  def new
    @mailing_list = MailingList.find(params[:mailing_list_id])
    @post = Post.new(mailing_list: @mailing_list)
    if params[:reply_to_id].present?
      @reply_to = Post.find(params[:reply_to_id])
      @post.subject = "Re: #{@reply_to.subject}"
    end
  end

  private

  def post_params
    params_without_mobile.require(:post).permit(:body, :from_name, :from_email, :subject)
  end
end
