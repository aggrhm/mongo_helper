module MongoHelper

  module Assignment

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def mongo_helper_assignment_keys!(db=:mongoid)
        include MongoHelper::Model

        field :oid
        field :tp, as: :type, type: Integer
        field :rl, as: :role, type: Integer
        field :mth, as: :meta, type: Hash, default: {}

        mongoid_timestamps!
      end
    end

    def to_model_api(model, opt=:min)
      m = self.send model.to_sym
      ret = m.to_api(opt)
      ret[:assignment] = self.to_api
      return ret
    end

    def to_api(opt=:default)
      ret = {}
      ret[:type] = self.type
      ret[:role] = self.role
      ret[:created_at] = self.created_at.to_i
      ret[:updated_at] = self.updated_at.to_i
      return ret
    end

  end

end
