class User < ApplicationRecord
  sharer

  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships
  has_many :record_activities

  validates :name, uniqueness: true

  def self.current
    Thread.current[:current_user]
  end

  def self.current=(usr)
    Thread.current[:current_user] = usr
  end

  def can_edit?(resource) # overrides sharer can_edit?
    check_resource(resource)
    resource.shareable_owner == self ||
      shared_with_me.where(edit: true).exists?(edit: true, resource: resource) ||
      groups.map{|g| g.shared_with_me.where(edit: true).exists?(edit: true, resource: resource) }.include?(true)
  end

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
