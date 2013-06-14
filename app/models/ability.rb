class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, User, :id => user.id
    can :manage, Book, :user_id => user.id
  end
end
