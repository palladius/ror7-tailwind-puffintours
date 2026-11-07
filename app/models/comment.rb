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

  validates :vote, inclusion: { in: 0..5 }, allow_nil: true
  validate :body_or_vote_present

  after_commit -> { Article.bump_cache_version! }

  private

  def body_or_vote_present
    if body.to_s.strip.blank? && vote.to_i <= 0
      errors.add(:base, "Seleziona da 1 a 5 stelle o scrivi un commento.")
    end
  end
end
