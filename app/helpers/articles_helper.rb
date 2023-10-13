module ArticlesHelper
  def author_and_date(article)
#    "by #{article.user.name.capitalize} | #{format_time(article.created_at.to_date)} | #{article.content_date.to_s} "
    "by #{article.user.name.capitalize} | #{article.content_date.to_s} "
  end
end
