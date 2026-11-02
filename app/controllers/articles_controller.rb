class ArticlesController < ApplicationController
  # before_action :authenticate_user!, only: %i[new create edit update destroy]
  # before_action :set_article, only: %i[show edit update destroy]
  # #before_action :authenticate_user!

  # authorize_resource
  load_and_authorize_resource

  def index
    @q = Article.ransack(params[:q])
    scope = @q.result.includes(:user, :tags, :comments, :votes_for, :rich_text_body, main_image_attachment: :blob).order(created_at: :desc)
    scope = scope.tagged_with(params[:tag]) if params[:tag].present?
    @pagy, @articles = pagy(scope, items: 6)
  end

  def show
  end

  def new
    @article = Article.new
  end

  def edit
  end

  def create
    @article = Article.new(article_params.merge(user: current_user))

    if @article.save
      redirect_to @article, notice: "Article was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @article.update(article_params)
      redirect_to @article, notice: "Article was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy

    redirect_to articles_path, notice: "Article was successfully destroyed."
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :body, :published, :article_type, :content_date, :tag_list, :main_image, :main_image_synopsis, :article_synopsis)
  end

  def tag_cloud
    @tags = Article.tag_counts_on(:tags)
  end

end
