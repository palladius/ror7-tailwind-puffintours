class CommentsController < ApplicationController
  before_action :set_article
  before_action :set_comment, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, only: %i[new create edit update destroy]

  # GET /articles/:article_id/comments
  def index
    @comments = @article.comments
  end

  # GET /articles/:article_id/comments/1
  def show
  end

  # GET /articles/:article_id/comments/new
  def new
    @comment = @article.comments.new
  end

  # GET /articles/:article_id/comments/1/edit
  def edit
  end

  # Rucc changed according to https://dev.to/jamgar/how-to-create-a-comment-and-reply-system-in-ruby-on-rails-10ld
  # POST /articles/:article_id/comments
  def create
    @comment = @article.comments.new(comment_params.merge(user: current_user)) # manually merging user inside hash, otherwise it worn work!

    if @comment.save
      redirect_to @article, notice: "Comment was successfully created."
    else
      redirect_to @article, notice: "❌ Comment couldnt be created, sorry (cu=#{current_user.id}). Errors: #{@comment.errors.full_messages.to_sentence}", status: :unprocessable_entity
    end
  end

  # PATCH/PUT /articles/:article_id/comments/1
  def update
    if @comment.update(comment_params)
      redirect_to [@article, @comment], notice: "Comment was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /articles/:article_id/comments/1
  def destroy
    article = @comment.article || @article
    @comment.destroy
    redirect_to article, notice: "Comment was successfully destroyed.", status: :see_other
  end

  private
    def set_article
      @article = Article.find(params[:article_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = @article.comments.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.require(:comment).permit(:body, :article_id, :parent_id, :vote, :internal_notes, :active, :user_id)
    end
end
