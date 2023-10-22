module ArticlesHelper

  def author_and_date(article)
    #    "by #{article.user.name.capitalize} | #{format_time(article.created_at.to_date)} | #{article.content_date.to_s} "
    published_emoji = article.published.nil? ? '0️⃣' :
      article.published ? '🌍' : '🕵️'
    "by #{article.user.name.capitalize} | #{article.content_date.to_s} #{published_emoji}"
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

  def render_main_image(article)
    if article.main_image and article.main_image.is_a?(ActiveStorage::Attached::One) and article.main_image.attached?
#      return <p><%= image_tag(article.main_image.representation(resize_to_limit: [100, 100]))  rescue "Some error: #{$!}" %></p>
      return image_tag(article.main_image.representation(resize_to_limit: [100, 100]))  rescue "Some error: #{$!}"
    else
      "(🙆‍♂️ no img)"
    end
  end
end
