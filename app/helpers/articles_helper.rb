module ArticlesHelper
  def author_and_date(article)
#    "by #{article.user.name.capitalize} | #{format_time(article.created_at.to_date)} | #{article.content_date.to_s} "
    "by #{article.user.name.capitalize} | #{article.content_date.to_s} "
  end

  def render_tags(article)
    ret = ''
    article.tags.each{ |tag|
      css_class = ''
      #ret += link_to(tag.name, { :action => :tag, :id => tag.name }, :class => css_class)
      ret += link_to("##{tag.name}", "/tags/#{tag.name}") + ' '
#      ret += "##{tag.name} " # ).html_safe
    }
    ret.html_safe
  end

  # a.votes_for.count
  def render_votes(article)
    '👏' * article.votes_for.count
  end
end
