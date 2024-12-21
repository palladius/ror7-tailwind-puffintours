
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

  # def ransackable_attributes
  #   ["title", "body", "content_date", "published"]
  # end
  def self.ransackable_attributes(auth_object = nil)
    ["title", "body", "content_date", "published"]
  end
  def self.ransackable_associations(auth_object = nil)
    ["comments"]
  end

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

end
