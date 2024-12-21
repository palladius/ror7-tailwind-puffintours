module ArticlesHelper

  def author_and_date(article)
    #    "by #{article.user.name.capitalize} | #{format_time(article.created_at.to_date)} | #{article.content_date.to_s} "
    published_emoji = article.published.nil? ? '0️⃣' :
      article.published ? '🌍' : '🕵️'
    "by <b>#{article.user.name.capitalize}</b> | #{article.content_date.to_s} #{published_emoji}".html_safe
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

  def render_main_image_card(article)
    return unless article.main_image&.attached?

    #cursor_image = image_tag(article.main_image.representation(resize_to_limit: [800, 600]))

    content_tag(:div, class: 'card float-end ms-3', style: 'width: 50%') do
      concat(
        image_tag(
          article.main_image.representation(resize_to_limit: [800, 600]),
          class: 'card-img-top',
          alt: article.title
        ) # rescue "Image loading error: #{$!}"
      )
      image_synopsis_prequel = content_tag(:b, '♊️ Generated image description:')
      image_synopsis_sequel = content_tag(:i, article.main_image_synopsis)
      if article.main_image_synopsis.present?
        concat(
          content_tag(:div, class: 'card-body') do
            content_tag(:p, image_synopsis_prequel + image_synopsis_sequel,
              class: 'card-text text-muted fst-italic small mb-0')
          end
        )
      end
    end
  end

end
