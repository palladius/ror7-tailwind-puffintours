module CommentsHelper

  def star_rating(apple_vote) # 0..5
    '⭐️' * apple_vote
  end
end
