# Idea and implementation from here: https://dev.to/jamgar/how-to-create-a-comment-and-reply-system-in-ruby-on-rails-10ld
class Comment < ApplicationRecord
  belongs_to :article
  belongs_to :user
  validates :body, presence: true

end
