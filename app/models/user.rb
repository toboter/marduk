class User < ApplicationRecord

  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships

  #extend commentable
  def can_comment?
    true
  end
  #end extend

  def can_edit?
    true
  end

  def can_create?
    true
  end

end
