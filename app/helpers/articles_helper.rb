module ArticlesHelper
  PUFFIN_COVERS = [
    "logo/puffin-suitcase.png",
    "logo/puffin cappello giallo.png",
    "logo/puffinMcMuffin.png",
    "logo/puffino con collana di anelli.png"
  ].freeze

  COVER_GRADIENTS = [
    "from-amber-400/35 via-orange-300/25 to-rose-400/35",
    "from-sky-400/35 via-cyan-300/25 to-indigo-400/35",
    "from-emerald-400/30 via-teal-300/25 to-sky-400/35",
    "from-violet-400/35 via-fuchsia-300/25 to-amber-300/35"
  ].freeze

  NOISY_SYNOPSIS_PATTERNS = [
    /There is no actual article content to summarize/i,
    /doesn't convey any meaningful information/i,
    /nothing meaningful to extract/i,
    /Gemini API Error/i,
    /Please provide the HTML/i
  ].freeze

  def author_and_date(article)
    published_emoji = article.published.nil? ? '📝' : (article.published ? '🌍' : '🕵️')
    author_name = article.user&.name.presence || "Puffin Explorer"
    date_str = (article.content_date || article.created_at&.to_date).to_s
    "by <b class=\"text-slate-800\">#{ERB::Util.html_escape(author_name.capitalize)}</b> · #{ERB::Util.html_escape(date_str)} #{published_emoji}".html_safe
  end

  def render_tags(article)
    return "".html_safe if article.tags.blank?

    safe_join(
      article.tags.first(5).map do |tag|
        link_to(
          "##{tag.name}",
          "/tags/#{ERB::Util.url_encode(tag.name)}",
          class: "card-action-z inline-flex items-center rounded-full bg-amber-500/10 hover:bg-amber-500/20 border border-amber-500/25 px-2.5 py-0.5 text-xs font-semibold text-amber-800 no-underline transition-colors"
        )
      end,
      " "
    )
  end

  def render_votes(article)
    count = article.votes_for.count
    count > 0 ? "👏 #{count}" : "👏 0"
  end

  # Blob #163 (2026-11-03) is the first blob uploaded to gs://puffintours-assets.
  # Earlier blobs (2023-2025) belong to old local disks or disabled buckets.
  PUFFIN_ASSETS_MIN_BLOB_ID = 163

  def blob_available_as_image?(blob)
    return false unless blob.present? && blob.image?

    service = ActiveStorage::Blob.service
    if service.respond_to?(:path_for)
      File.exist?(service.path_for(blob.key))
    else
      blob.service_name == "gcs" && blob.id.to_i >= PUFFIN_ASSETS_MIN_BLOB_ID
    end
  rescue StandardError
    false
  end

  def cover_image_blob(article)
    if article.main_image&.attached? && blob_available_as_image?(article.main_image.blob)
      return article.main_image.blob
    end

    if article.rich_text_body&.embeds_blobs.present?
      trix_blob = article.rich_text_body.embeds_blobs.find { |b| blob_available_as_image?(b) }
      return trix_blob if trix_blob
    end

    nil
  rescue StandardError
    nil
  end

  def local_blob_available?(article)
    cover_image_blob(article).present?
  end

  def fast_blob_url(attachment_or_blob)
    blob = attachment_or_blob.respond_to?(:blob) ? attachment_or_blob.blob : attachment_or_blob
    if ActiveStorage::Blob.service.class.name.include?("GCS")
      "https://storage.googleapis.com/#{GcsBucket}/#{blob.key}"
    else
      url_for(blob)
    end
  end

  def fallback_puffin_asset(article)
    idx = (article.id || 0) % PUFFIN_COVERS.size
    PUFFIN_COVERS[idx]
  end

  def fallback_cover_gradient(article)
    idx = (article.id || 0) % COVER_GRADIENTS.size
    COVER_GRADIENTS[idx]
  end

  def article_type_label(article)
    raw_type = article.article_type.presence || "article"
    t = raw_type.to_s.downcase
    title_down = article.title.to_s.downcase
    # Use preloaded article.tags in memory instead of article.tag_list (which triggers N+1 SQL queries)
    tag_names = article.tags.map { |tg| tg.name.to_s.downcase }
    icon = if t.include?("trip") || t.include?("travel") || tag_names.intersect?(%w[barcelona spain trip])
      "🧳"
    elsif t.include?("video") || title_down.include?("video")
      "🎬"
    elsif t.include?("family") || tag_names.include?("carlessos")
      "👨‍👩‍👦‍👦"
    else
      "📰"
    end
    "#{icon} #{raw_type.capitalize}"
  end

  def render_card_cover(article)
    cover_blob = cover_image_blob(article)
    fallback_asset = asset_path(fallback_puffin_asset(article))
    gradient_cls = fallback_cover_gradient(article)

    img_src = cover_blob ? fast_blob_url(cover_blob) : fallback_asset

    visibility_badge = if article.published == false
      content_tag(
        :span,
        "🔑",
        title: "Private (Family Only)",
        class: "inline-flex h-8 w-8 items-center justify-center rounded-full bg-slate-900/55 backdrop-blur-md border border-amber-300/50 text-sm shadow-sm"
      )
    else
      content_tag(
        :span,
        "🌍",
        title: "Public Story",
        class: "inline-flex h-8 w-8 items-center justify-center rounded-full bg-white/45 backdrop-blur-md border border-white/60 text-sm opacity-80 shadow-sm"
      )
    end

    type_pill = content_tag(
      :span,
      article_type_label(article),
      class: "rounded-full bg-slate-900/45 backdrop-blur-md border border-white/30 px-3 py-1 text-[11px] font-semibold tracking-wide text-white/95 shadow-sm"
    )

    content_tag(:div, class: "card-cover-wrap bg-gradient-to-br #{gradient_cls}") do
      concat(
        image_tag(
          img_src,
          alt: article.title,
          class: "card-media-img object-cover",
          data: { fallback_src: fallback_asset },
          onerror: "this.onerror=null;this.src='#{fallback_asset}';"
        )
      )
      concat(
        content_tag(:div, class: "absolute inset-x-0 top-0 p-3 flex items-center justify-between gap-2 pointer-events-none") do
          type_pill + visibility_badge
        end
      )
    end
  end

  def render_main_image(article)
    cover_blob = cover_image_blob(article)
    fallback_asset = asset_path(fallback_puffin_asset(article))
    if cover_blob
      image_tag(
        fast_blob_url(cover_blob),
        alt: article.title,
        class: "rounded-2xl shadow-md max-h-96 w-auto object-cover border border-white/80",
        data: { fallback_src: fallback_asset },
        onerror: "this.onerror=null;this.src='#{fallback_asset}';"
      )
    else
      content_tag(:div, class: "inline-flex items-center gap-3 rounded-2xl bg-gradient-to-r #{fallback_cover_gradient(article)} p-3 border border-white/80 shadow-sm") do
        image_tag(fallback_asset, alt: article.title, class: "h-16 w-16 rounded-xl object-contain bg-white/70 p-1") +
          content_tag(:div, class: "text-xs text-slate-700 pr-2") do
            if article.main_image&.attached?
              content_tag(:div, "☁️ Media stored on GCS bucket (#{GcsBucket})", class: "font-semibold text-slate-800") +
                content_tag(:div, "Showing Puffin emblem while cloud object is unavailable", class: "text-slate-500")
            else
              content_tag(:div, "🐧 Puffin Tours Story", class: "font-semibold text-slate-800") +
                content_tag(:div, "No cover photo attached yet", class: "text-slate-500")
            end
          end
      end
    end
  end

  def render_main_image_card(article)
    return unless article.main_image&.attached?

    fallback_asset = asset_path(fallback_puffin_asset(article))
    cover_blob = cover_image_blob(article)
    img_source = cover_blob ? fast_blob_url(cover_blob) : fallback_asset

    content_tag(:div, class: "card my-4 max-w-md") do
      concat(
        image_tag(
          img_source,
          class: "rounded-2xl w-full object-cover max-h-72",
          alt: article.title,
          data: { fallback_src: fallback_asset },
          onerror: "this.onerror=null;this.src='#{fallback_asset}';"
        )
      )
      if article.main_image_synopsis.present?
        concat(
          content_tag(:div, class: "mt-3 text-xs text-slate-600 italic") do
            content_tag(:b, "♊️ Gemini Vision: ", class: "not-italic text-amber-800") + article.main_image_synopsis
          end
        )
      end
    end
  end

  def clean_gemini_synopsis(article)
    syn = article.article_synopsis.to_s.strip
    return nil if syn.blank?
    return nil if NOISY_SYNOPSIS_PATTERNS.any? { |pat| syn.match?(pat) }

    syn
  end

  def clean_body_excerpt(article, length = 140)
    raw = strip_tags(article.body&.body&.to_html.to_s).squish
    return "No body text written yet — click to read or edit this story." if raw.blank?
    if raw.match?(/\A(asd|asdf|gfh)[a-z0-9\s]*\z/i)
      return "Quick sandbox test note (“#{truncate(raw, length: 32)}”)."
    end

    truncate(raw, length: length)
  end

  def gemini_or_truncated_body(article, length = 160)
    clean_gemini_synopsis(article) || clean_body_excerpt(article, length)
  end
end
