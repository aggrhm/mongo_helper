module MongoHelper
	module Storable
		extend ActiveSupport::Concern

		module ClassMethods
			def demongoize(obj)
				ret = self.new
				ret.from_hash(obj) unless obj.nil?
				return ret
			end

			def mongoize(obj)
				obj.mongoize
			end

			def evolve(obj)
				obj.mongoize
			end

			def resizable?
				true
			end
		end

		def mongoize
			self.to_hash.stringify_keys
		end

		def resizable?
			true
		end

	end
end
