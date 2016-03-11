module MongoHelper

  module AssociationsCache

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods

      def cache_for(field, opts)
        @associations_cache_def ||= {}.with_indifferent_access
        # fix opts
        if !opts[:class].is_a?(Proc)
          if opts[:class].is_a?(Symbol)
            opts[:class] = opts[:class].to_proc
          else
            cl = opts[:class]
            opts[:class] = lambda {|m| cl}
          end
        end
        opts[:id] = opts[:id].to_proc
        @associations_cache_def[field] = opts
      end

      def update_cache(models, fields, options={})
        models = [models] if !models.is_a?(Array)
        fields = [fields] if !fields.is_a?(Array)
        fields.each do |field|
          opts = @associations_cache_def[field]
          next if opts.nil?
          # setup
          id_fn = opts[:id]
          cl_fn = opts[:class]
          col_h = Hash.new do |hash, key|
            hash[key] = {ids: []}
          end

          if options[:reload] == true
            rms = models
          else
            rms = models.select{|m| m.cache[field].nil?}
          end

          # get all ids and classes
          rms.each do |m|
            cl = cl_fn.call(m)
            cln = cl.to_s
            ids = id_fn.call(m)
            col_h[cln][:ids] << ids
            col_h[cln][:class] ||= cl
          end

          # find association models
          col_h.each do |cln, opts|
            opts[:ids] = opts[:ids].flatten.uniq.reject{|id| id.nil?}
            cl = opts[:class]
            ids = opts[:ids]
            opts[:models] = {}
            cl.find(ids).to_a.each do |sm|
              opts[:models][sm.id.to_s] = sm
            end
          end
          #puts "#{field}: #{col_h.inspect}"

          # store association models in cache
          rms.each do |m|
            id = id_fn.call(m)
            cl = cl_fn.call(m)
            cln = cl.to_s
            if id.nil?
              m.cache[field] = nil
            elsif id.is_a?(Array)
              m.cache[field] = id.collect{|i|
                col_h[cln][:models][i.to_s]
              }.reject{|m| m.nil?}
            else
              m.cache[field] = col_h[cln][:models][id.to_s]
            end
          end
          #puts "#{field}: #{m.cache[field].inspect}"

        end
      end

    end ## END CLASSMETHODS

    def update_cache(fields, opts={})
      self.class.update_cache([self], fields, opts)
    end

    def cache
      @cache ||= {}
    end

  end

end
