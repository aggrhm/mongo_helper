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
      ActiveSupport::SecureRandom.base64(15).tr('+/=', '').strip.delete("\n")
    end
  end

end
