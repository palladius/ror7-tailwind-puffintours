class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    # Admin can manage all
    if user.admin?
      can :manage, :all
    else
      # Regular users can edit their own articles
      can :read, Article
      can [:update, :edit, :destroy], Article, user_id: user.id
    end
  end
end
