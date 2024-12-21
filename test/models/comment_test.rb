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
  # test "the truth" do
  #   assert true
  # end
end
