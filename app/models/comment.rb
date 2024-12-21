# == Schema Information
#
# Table name: comments
#
#  id             :integer          not null, primary key
#  body           :text
#  article_id     :integer
#  parent_id      :integer
#  vote           :integer          default(0)
#  internal_notes :text
#  active         :boolean          default(TRUE)
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Idea and implementation from here: https://dev.to/jamgar/how-to-create-a-comment-and-reply-system-in-ruby-on-rails-10ld
class Comment < ApplicationRecord
  belongs_to :article
  belongs_to :user
  validates :body, presence: true

end
