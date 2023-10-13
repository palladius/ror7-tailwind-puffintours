
# 2. migration:
#add_column :articles, :article_type, :string, default: 'article'
#add_column :articles, :content_date, :date
#add_column :articles, :published, :boolean, default: true

class Article < ApplicationRecord
  belongs_to :user

  # First run bundle install with it and posssibly migreation.. or just read instruction of gem :)
  # I'm ogfgline on a plane from BCN and having some difficulties.
  #acts_as_taggable_on :tags

  has_rich_text :body

  validates :title, :body, presence: true
  validates :title, length: { minimum: 5 }

  before_save :set_date_if_null
  def set_date_if_null
    self.content_date ||= (self.created_at.to_date rescue  Date.today)
  end
end
