module MongoHelper

  module Model

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def attr_alias(new_attr, old_attr)
        alias_method(new_attr, old_attr)
        alias_method("#{new_attr}=", "#{old_attr}=")
      end

      def embedded_in_mm(owner_name)
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
          val = send(enum)
          if opt.class == Array
            return opt.collect{|a| opts[a]}.include? val
          else
            return val == opts[opt]
          end
        end
        define_method "#{enum}!" do |opt|
          send("#{enum}=", opts[opt])
          if self.respond_to? "#{enum}_changed_at"
            send("#{enum}_changed_at=", Time.now)
          end
        end
      end

      def mongoid_timestamps!
        if MongoHelper.options[:timestamp_format] == :long
          include Mongoid::Timestamps
        else
          include Mongoid::Timestamps::Short
        end
      end

      def mongoid_timestamps_long!
        include Mongoid::Timestamps
      end

      def mongoid_custom_timestamps!
        field :c_at, as: :created_at, type: Time
        field :u_at, as: :updated_at, type: Time

        set_callback(:create, :before) do |doc|
          if doc.created_at.nil?
            time = Time.now.utc
            doc.created_at = time
            doc.updated_at = time
          end
        end
        set_callback(:update, :before) do |doc|
          doc.updated_at = Time.now.utc
        end
      end

      def new_embedded
        a = self.new
        a.id = BSON::ObjectId.new
        a
      end

      def mongo_new
        a = self.new
        #a.id = BSON::ObjectId.new
        a.created_at = Time.new if a.respond_to? :created_at
        a.updated_at = Time.new if a.respond_to? :updated_at
        a.is_new = true if a.respond_to? :is_new
        return a
      end

    end


    def self.ArrayOf(klass)
      Class.new(Array) do |slf|
        def slf.demongoize(obj)
          ret = self.new
          unless obj.nil?
            obj.each{|el| ret << klass.from_hash(el)}
          end
          return ret
        end

        def slf.evolve(obj)
          obj.mongoize
        end

        def slf.mongoize(obj)
          obj.mongoize
        end

        def mongoize
          self.collect{|el| el.to_hash.stringify_keys}
        end
      end
    end

    def self.HashOf(klass)
      Class.new(klass) do |slf|
        def slf.demongoize(obj)
          ret = self.new
          ret.from_hash(obj) unless obj.nil?
          return ret
        end

        def slf.mongoize(obj)
          obj.mongoize
        end

        def slf.evolve(obj)
          obj.mongoize
        end

        def mongoize
          self.to_hash.stringify_keys
        end
      end
    end
    
    # INSTANCE METHODS

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
      arr.select{|m| m.id == id || m.id.to_s == id}.first
    end

    def absorb_hash(model_key, val)
      val = JSON.parse(val) if val.is_a?(String)
      param = self.send(model_key)
      val.keys.each do |key|
        param[key] = val[key]
      end
    end


  end

end
