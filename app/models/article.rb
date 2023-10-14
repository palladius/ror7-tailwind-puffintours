
# 2. migration:
#add_column :articles, :article_type, :string, default: 'article'
#add_column :articles, :content_date, :date
#add_column :articles, :published, :boolean, default: true

class Article < ApplicationRecord
  belongs_to :user

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

  def set_date_if_null
    self.content_date ||= (self.created_at.to_date rescue  Date.today)
  end

  # Th4ese are just to test Tagbablity and Votability
  def various_tests
    @user = User.first
    # https://github.com/mbleigh/acts-as-taggable-on
    self.tag_list.add("puffintours")
    self.tag_list.add("awesome", "slick")
    self.liked_by(@user)
  end
end
