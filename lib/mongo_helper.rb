module MongoHelper
  extend ActiveSupport::Concern

  module ClassMethods
    def attr_alias(new_attr, old_attr)
      alias_method(new_attr, old_attr)
      alias_method("#{new_attr}=", "#{old_attr}=")
    end

    def embedded_in(owner_name)
      alias_method(owner_name, :_parent_document)
      alias_method("#{owner_name}=", "_parent_document=")
    end

    def random_token
      # use base64url as defined by RFC4648
      SecureRandom.base64(15).tr('+/=', '').strip.delete("\n")
    end

		def enum_methods!(enum, opts)
			enum = enum.to_s
			define_method "#{enum}?" do |opt|
				send(enum) == opts[opt]
			end
			define_method "#{enum}!" do |opt|
				send("#{enum}=", opts[opt])
			end
		end

		def new_embedded
			a = self.new
			a.id = BSON::ObjectId.new
			a
		end

		def mongo_new
			a = self.new
			a.id = BSON::ObjectId.new
			a.created_at = Time.new if a.respond_to? :created_at
			a.updated_at = Time.new if a.respond_to? :updated_at
			return a
		end
	end

	module InstanceMethods
		def save_embedded!(field, obj)
			return false unless obj.valid?
			if !self.find_embedded(field, obj.id)
				arr = self.send field.to_sym
				arr << obj
			end
			self.save
		end

		def delete_embedded!(field, obj)
			return false if obj.nil?
			if self.find_embedded(field, obj.id)
				arr = self.send field.to_sym
				arr.delete_if {|el| el.id == obj.id}
			end
			self.save
		end

		def find_embedded(field, id)
			arr = self.send field.to_sym
			arr.find {|m| m.id == id || m.id.to_s == id}
		end
  end

end
