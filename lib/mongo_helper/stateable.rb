module MongoHelper

  module Stateable

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods

      def states
        @states ||= {}
      end

      def state(enum, val)
        states[enum] = val
      end

      def stateable_mongoid_keys!
        include MongoHelper::Model

        field :st, as: :state, type: Integer, default: 1
        field :st_at, as: :state_changed_at, type: Time

        enum_methods! :state, states

        scope :with_state, lambda {|st|
          # convert to int
          ar = st.is_a?(Array) ? st : [st]
          ar = ar.collect {|v|
            if v.is_a?(String)
              if states.keys?(v.to_sym)
                states[v.to_sym]
              else
                v.to_i
              end
            elsif v.is_a?(Symbol)
              states[v]
            else
              v
            end
          }
          where('st' => {'$in' => ar})
        }
        scope :has_state, lambda {|st|
          with_state(st)
        }
        scope :active, lambda {
          where("st" => {'$in' => [nil, states[:active]]})
        }
        scope :archived, lambda {
          where(st: states[:archived])
        }
        scope :not_deleted, lambda {
          where(:st.ne => states[:deleted])
        }
      end

    end

    def update_state!(state)
      self.state! state
      self.save(validate: false)
      return self.state
    end

  end

end
