module Marduk

  module RecordActivity
    
    def actable(options = {}) 
      include Marduk::Models::Actable
      # Add some relations
      has_many :record_activities, as: :resource, class_name: 'RecordActivity'
      has_many :actors, through: :record_activities

      # _action: to add creator on actable_create in RecordActivity
      # @activity.actor = user
      # @activity.resource = resource
      # @activity.activity_type = 'Created'

      class_attribute :actable_options
      self.actable_options = options
    end
  end
end