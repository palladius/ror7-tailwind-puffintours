class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Article

    return unless user&.persisted?

    if user.admin?
      can :manage, :all
    else
      # Regular logged-in users can create articles and edit/destroy their own
      can :create, Article
      can [:update, :edit, :destroy], Article, user_id: user.id
    end
  end
end
