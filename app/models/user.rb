class User < ApplicationRecord
  sharer

  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships
  has_many :record_activities

  validates :name, uniqueness: true

  # can_edit? Resource can_read? Resource by shareable_model through sharer
  #extend commentable
  def can_comment?
    true
  end
  #end extend

  def can_create?
    true
  end

  def is_admin?
    app_admin
  end

  def group_list
    groups.map(&:name).join("; ")
  end
  
  def group_list=(names)
    self.groups = names.reject { |c| c.empty? }.split(";").flatten.map do |n|
      Group.where(name: n).first
    end
  end

end
