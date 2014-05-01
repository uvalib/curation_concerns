module Worthwhile
  module Ability
    extend ActiveSupport::Concern
    included do
      self.ability_logic += [:worthwhile_permissions]
    end

    def worthwhile_permissions
      
      can :create, Worthwhile::ClassifyConcern unless current_user.new_record?
      # alias_action :confirm, :copy, :to => :update
# 
#       if user_groups.include? 'admin'
#         can [:discover, :show, :read, :edit, :update, :destroy], :all
#       end
# 
#       can [:show, :read, :update, :destroy], [Curate.configuration.curation_concerns] do |w|
#         u = ::User.find_by_user_key(w.owner)
#         u && u.can_receive_deposits_from.include?(current_user)
#       end

    end

  end
end

