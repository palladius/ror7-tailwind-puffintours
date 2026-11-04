# == Schema Information
#
# Table name: articles
#
#  id                  :integer          not null, primary key
#  title               :string
#  body                :text
#  user_id             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  article_type        :string           default("article")
#  content_date        :date
#  published           :boolean          default(TRUE)
#  article_synopsis    :text
#  main_image_synopsis :text
#
# 2. migration:
#add_column :articles, :article_type, :string, default: 'article'
#add_column :articles, :content_date, :date
#add_column :articles, :published, :boolean, default: true


class Article < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  # First ActiveStorage manual thingy on GCS..
  has_one_attached :main_image

  # First run bundle install with it and posssibly migreation.. or just read instruction of gem :)
  # I'm ogfgline on a plane from BCN and having some difficulties.
  acts_as_taggable_on :tags

  #https://www.rubydoc.info/gems/jy-acts_as_votable
  acts_as_votable

  has_rich_text :body

  before_validation :ensure_body_fallback
  validates :title, presence: true, length: { minimum: 2 }

  before_save :set_date_if_null
  before_save :various_tests # just fo testing
  after_commit :enqueue_missing_synopses, on: %i[create update]

  def ensure_body_fallback
    if body.blank? && !main_image.attached? && title.present?
      self.body = "<p>#{ERB::Util.html_escape(title)}</p>"
    end
  end



  def self.ransackable_attributes(auth_object = nil) = ["title", "body", "content_date", "published", "article_synopsis", "main_image_synopsis"]
  def self.ransackable_associations(auth_object = nil) =  ["comments", "user"]  # Add "user" to the list

  def set_date_if_null
    self.content_date ||= (self.created_at.to_date rescue  Date.today)
  end

  # Th4ese are just to test Tagbablity and Votability
  def various_tests
    @user = User.first
    # https://github.com/mbleigh/acts-as-taggable-on
    self.tag_list.add("puffintours")
    #self.tag_list.add("awesome", "slick")
    self.liked_by(@user) if @user
  end


  # for chatring purposes..
  def user_email
    self.user&.email
  end

  def editable_by?(user)
    # user could be null..
    return false unless user.present?
    return true if user.admin?
    user == self.user
  end

  # => [nil, nil, 3, 3, 3, nil, 1, 5] => [3, 3, 3, 1, 5, 4]
  def average_vote
    # TODO cache / compute efficiently
    votes1to5 = comments.map { |c| c.vote if c.vote.to_i > 0 }.compact_blank
    return 0.0 if votes1to5.empty?
    votes1to5.sum.to_f / votes1to5.count
  end

  def generate_summary
    # lets check if its empty - if not return with a message
    return if self.article_synopsis.present?
    raise "PUFFIN_TOURS_GEMINI_API_KEY is not set" if PUFFIN_TOURS_GEMINI_API_KEY.blank?

    query = "Summarize this article. Start the summary with an emoji representative of the language (🇬🇧, 🇫🇷, 🇪🇸, ..) and then the summary: #{self.body.to_plain_text rescue self.body}"
    client = GeminiAiVisionClientLogan || GeminiAiVisionClientLocalADC
    raise "Gemini client not configured" unless client

    result = client.stream_generate_content(
      { contents: [{ role: 'user', parts: [{ text: query }] }] }
    )
    chat_completion = result.map do |chunk|
      chunk.dig('candidates', 0, 'content', 'parts', 0, 'text')
    end.compact.join('').strip

    if chat_completion.present?
      self.article_synopsis = chat_completion
      update_column(:article_synopsis, chat_completion) if persisted?
    end
    { text_summary: chat_completion, save_ok: chat_completion.present? }
  end

  def self.generate_summaries_for_all_articles
    Article.all.each do |article|
        article.generate_summary
    end
  end


  def self.generate_image_summaries_for_all_articles
#    Article.where(main_image_synopsis: '').map do |article|
    Article.all.map do |article|
        puts "Article.##{article.id} image synopsis is being processed..."
        article.generate_image_synopsis
    end
  end

  def self.generate_all
    a = 42 # self.generate_summaries_for_all_articles
    b = self.generate_image_summaries_for_all_articles
    return {text_summaries: a, image_summaries: b}
  end


  # app/models/article.rb:140:in `generate_image_synopsis': the server responded with status 404 (Faraday::ResourceNotFound)
  def generate_image_synopsis
    return self.main_image_synopsis if self.main_image_synopsis.present?

    image_size = main_image_blob.byte_size rescue -1

    if self.main_image.blank?
      return "Image for Article.##{self.id} is non existing"
    end

    if image_size < 1000
      return "Image for Article.##{self.id} is too small or non existing (image_size=#{image_size})"
    end

    require 'base64'

    # Assuming self has an image attachment named 'image'
    image_data = self.main_image.blob.download rescue nil
    # triggers ActiveStorage::FileNotFoundError, lets catch it..
    return "Image.blob.download for Article.##{self.id} is non existing" if image_data.blank?

    base64_image = Base64.strict_encode64(image_data)

    puts("Image is ok (b64 is #{base64_image.size/1024}KB), sending to Gemini to get a description...")
    client = GeminiAiVisionClientLogan || GeminiAiVisionClientLocalADC
    return "Gemini client not available" unless client

    result = client.stream_generate_content(
      { contents: [
        { role: 'user', parts: [
          { text: 'Please describe this image.' },
          { inline_data: {
            mime_type: self.main_image.content_type || 'image/jpeg',
            data: base64_image,
          } }
        ] }
      ] }
    )
    full_text = result.map do |chunk|
      chunk.dig('candidates', 0, 'content', 'parts', 0, 'text')
    end.compact.join('').strip
    if full_text.present?
      self.main_image_synopsis = full_text
      update_column(:main_image_synopsis, full_text) if persisted?
    end
    { image_summary: full_text, save_ok: full_text.present? }
  end


  private

  def enqueue_missing_synopses
    return if PUFFIN_TOURS_GEMINI_API_KEY.blank?
    return if article_synopsis.present? && (main_image_synopsis.present? || !main_image.attached?)

    article_id = id
    Thread.new do
      Rails.application.executor.wrap do
        art = Article.find_by(id: article_id)
        art&.send(:generate_missing_synopses)
      end
    rescue => e
      Rails.logger.warn("Async Gemini synopsis skipped/failed for Article ##{article_id}: #{e.message}")
    end
  end

  def generate_missing_synopses
    return if PUFFIN_TOURS_GEMINI_API_KEY.blank?
    if article_synopsis.blank?
      begin
        generate_summary
      rescue => e
        Rails.logger.warn("Gemini summary generation skipped/failed for Article ##{id}: #{e.message}")
      end
    end
    if main_image_synopsis.blank? && self.main_image.attached?
      begin
        generate_image_synopsis
      rescue => e
        Rails.logger.warn("Gemini image synopsis generation skipped/failed for Article ##{id}: #{e.message}")
      end
    end
  end

end
