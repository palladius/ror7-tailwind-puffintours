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

  validates :title, :body, presence: true
  validates :title, length: { minimum: 5 }

  before_save :set_date_if_null
  before_save :various_tests # just fo testing
  after_save :generate_missing_synopses



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
    self.liked_by(@user)
  end


  # for chatring purposes..
  def user_email
    self.user.email
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
    votes1to5 = comments.map{|c| c.vote if c.vote > 0}.compact_blank
    votes1to5.sum.to_f / votes1to5.count
  end

  def generate_summary
    # lets check if its empty - if not return with a message
    return if self.article_synopsis.present?
    # TODO
    raise "PUFFIN_TOURS_GEMINI_API_KEY is not set" if PUFFIN_TOURS_GEMINI_API_KEY.blank?
    llm = Langchain::LLM::GoogleGemini.new  api_key: PUFFIN_TOURS_GEMINI_API_KEY
    #messages = [{role: "user", content: "Summarize this article:\n\n----\n #{self.body}"}]
    query = "Summarize this article. Start the summary with an emoji representative of the language (🇬🇧, 🇫🇷, 🇪🇸, ..) and then the summary: #{self.body}"
    messages = [{ role: "user", parts: [{ text: query }]}]

    #llm.chat(messages: messages)
    response = llm.chat(messages: messages)
    chat_completion = response.chat_completion
    self.article_synopsis = chat_completion # chat_completion.choices[0].message.content
    self.save
    {text_summary: chat_completion, save_ok: true}
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
    result = GeminiAiVisionClientLocalADC.stream_generate_content(
      { contents: [
        { role: 'user', parts: [
          { text: 'Please describe this image.' },
          { inline_data: {
#            mime_type: self.main_image.content_type, # 'image/jpeg', # todo mime_type: self.main_image.content_type,
            mime_type: 'image/jpeg', # todo mime_type: self.main_image.content_type,
            data: base64_image,
          } }
        ] }
      ] }
    )
    #puts result.class
    #puts result.inspect
    full_text = result.map do |chunk|
      chunk.dig('candidates', 0, 'content', 'parts', 0, 'text')
    end.compact.join('')
    self.main_image_synopsis = full_text
    self.save
    #return full_text
    {image_summary: full_text, save_ok: true}

  end


  private

  # def generate_missing_synopses
  #   self.generate_summary
  #   self.generate_image_synopsis
  # end

  def generate_missing_synopses
    #if Rails.env.production? # Only run in production to save API calls
      if article_synopsis.blank? || main_image_synopsis.blank?
        # Option 1: Background job (recommended)
        #GenerateSynopsesJob.perform_later(self.id)

        # Option 2: Foreground (simpler but blocks save)
        generate_summary if article_synopsis.blank?
        generate_image_synopsis if main_image_synopsis.blank? and self.main_image.present?
      end
    #end
  end

end
