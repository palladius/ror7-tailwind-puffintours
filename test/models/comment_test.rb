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
require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "valid with vote only (minimalist 5-star rating without comment body)" do
    comment = Comment.new(article: articles(:one), user: users(:one), vote: 5, body: "")
    assert comment.valid?
  end

  test "valid with body only" do
    comment = Comment.new(article: articles(:one), user: users(:one), vote: 0, body: "Nice story!")
    assert comment.valid?
  end

  test "invalid when both body is blank and vote is zero" do
    comment = Comment.new(article: articles(:one), user: users(:one), vote: 0, body: "   ")
    assert_not comment.valid?
  end

  test "Article#average_vote computes mean of positive votes" do
    article = articles(:one)
    assert_in_delta 4.5, article.average_vote, 0.01
  end
end
