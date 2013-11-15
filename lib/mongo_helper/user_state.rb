module MongoHelper

  module UserState

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods

      def mongo_helper_user_state_keys_for(db)

        if db == :mongoid
          include MongoHelper::Model

          field :mc, as: :model_class, type: String
          field :mid, as: :model_id, type: Moped::BSON::ObjectId
          field :mth, as: :meta, type: Hash, default: Hash.new

          belongs_to :user, :foreign_key => 'uid', :class_name => 'User'

          mongoid_timestamps!
        end
      end

      def for_state(mc, mid, uid, &block)
        # find existing
        s = self.where(mid: mid, uid: uid).first
        if s.nil?
          s = self.new
          s.model_class = mc.to_s.camelize
          s.model_id = mid
          s.uid = uid
        end
        block.call(s) if block
        return s
      end

      def states_hash(mc, mids, uid)
        states = self.where(:mid => {'$in' => mids}, uid: uid)
        ret = {}
        states.each do |state|
          ret[state.mid] = state
        end
        return ret
      end


    end

  end

end
