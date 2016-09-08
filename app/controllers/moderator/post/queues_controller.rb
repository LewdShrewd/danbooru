module Moderator
  module Post
    class QueuesController < ApplicationController
      respond_to :html, :json
      before_filter :post_approvers_only

      def show
        cookies[:moderated] = Time.now.to_i

        if params[:per_page]
          cookies.permanent["mq_per_page"] = params[:per_page]
        end

        ::Post.without_timeout do
          @posts = ::Post.order("posts.id asc").pending_or_flagged.available_for_moderation(params[:hidden]).search(:tag_match => params[:query]).paginate(params[:page], :limit => per_page)
          @posts.each # hack to force rails to eager load
        end
        respond_with(@posts)
      end

      def random
        cookies[:moderated] = Time.now.to_i

        ::Post.without_timeout do
          @posts = ::Post.order("posts.id asc").pending_or_flagged.available_for_moderation(false).reorder("random()").limit(5)
          @posts.each # hack to force rails to eager load
        end

        respond_with(@posts)
      end

    protected

      def get_posts
      end

      def per_page
        cookies["mq_per_page"] || params[:per_page] || 25
      end
    end
  end
end
