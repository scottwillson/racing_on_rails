# frozen_string_literal: true

module Admin
  class PostsController < Admin::AdminController
    before_action :assign_mailing_list

    skip_before_action :require_administrator,
                       only: :create,
                       if: proc { |controller| controller.request.host == "0.0.0.0" }

    skip_before_action :verify_authenticity_token,
                       only: :create,
                       if: proc { |controller| controller.request.host == "0.0.0.0" }

    def index
      @posts = Post
               .where(mailing_list_id: @mailing_list.id)
               .order("date desc")
               .page(params[:page])
    end

    def new
      @post = @mailing_list.posts.build
      render :edit
    end

    def create
      @post = @mailing_list.posts.build(post_params)
      if Post.save(@post, @mailing_list)
        flash[:notice] = "Created #{@post.subject}"
        redirect_to edit_admin_mailing_list_post_path(@mailing_list, @post)
      else
        render :edit
      end
    end

    def edit
      @post = Post.find(params[:id])
    end

    def update
      @post = Post.find(params[:id])
      @post.attributes = post_params
      if Post.save(@post, @mailing_list)
        flash[:notice] = "Updated #{@post.subject}"
        redirect_to edit_admin_mailing_list_post_path(@mailing_list, @post)
      else
        render :edit
      end
    end

    def destroy
      @post = Post.find(params[:id])
      flash[:notice] = "Could not delete #{@post.subject}" unless Post.destroy(@post)
      redirect_to admin_mailing_list_posts_path(@mailing_list)
    end

    private

    def post_params
      params_without_mobile.require(:post).permit(:body, :date, :from_name, :from_email, :path, :subject, :title)
    end

    def assign_mailing_list
      @mailing_list = MailingList.find(params[:mailing_list_id])
    end
  end
end
