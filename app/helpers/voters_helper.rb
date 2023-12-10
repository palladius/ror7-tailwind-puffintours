module VotersHelper

  # Makes sense of an ActAsVotable article:
  # #<ActsAsVotable::Vote id: 11, votable_type: "Article", votable_id: 23, voter_type: "User", voter_id: 3, vote_flag: true, vote_scope: nil, vote_weight: 1, created_at: "2023-12-10 20:22:45.926529000 +0000", updated_at: "2023-12-10 20:22:45.926529000 +0000">
  def voter_info(v)
    # Points:
    # 👍👍: 5
    # 👍:   4
    # -:    3
    # 👎🏾:   2
    # 👎🏾👎🏾: 1
    stars = case v.vote_weight
      when 1 then v.vote_flag ? 4 : 2
      when 2 then v.vote_flag ? 5 : 1
      else v.vote_flag ? 6 : 0 # for debug then 5/1 so 1..5 :)
    end
    "#{v.voter_type} #{v.voter_id} (#{v.vote_flag ? '👍' : '👎🏾' } stars=#{stars}-> #{v.vote_weight})"

  end
end
