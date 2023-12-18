class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, only: %i[new create edit update destroy]

  # GET /comments
  def index
    @comments = Comment.all
  end

  # GET /comments/1
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end

  # Rucc changed according to https://dev.to/jamgar/how-to-create-a-comment-and-reply-system-in-ruby-on-rails-10ld
  # POST /comments
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.new(comment_params.merge(user: current_user)) # manually merging user inside hash, otherwise it worn work!
    #@comment = Comment.new(comment_params)

    if @comment.save
      #redirect_to @comment, notice: "Comment was successfully created."
      redirect_to @article, notice: "Comment was successfully created."
      #format.html { redirect_to @article, notice: 'Comment #{@comment.id rescue :boh} was successfully created.' } # changed the redirect to @article
    else
      redirect_to @article, notice: "❌ Comment couldnt be created, sorry (cu=#{current_user.id}). Errors: #{@comment.errors.full_messages.to_sentence}", status: :unprocessable_entity
      #render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /comments/1
  def update
    if @comment.update(comment_params)
      redirect_to @comment, notice: "Comment was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /comments/1
  def destroy
    @comment.destroy
    redirect_to comments_url, notice: "Comment was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.require(:comment).permit(:body, :article_id, :parent_id, :vote, :internal_notes, :active, :user_id)
    end
end
