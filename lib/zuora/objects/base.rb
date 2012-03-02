module Zuora::Objects
  # All Zuora objects extend from Zuora::Objects::Base, which provide the fundemental requirements
  # for handling creating, destroying, updating, and querying Zuora.
  class Base
    include Zuora::Attributes
    include Zuora::Validations
    include Zuora::Associations

    # generate a new instance of a Zuora object
    def initialize(attrs={}, &block)
      attrs.each do |name, value|
        self.send("#{name.to_s.underscore}=", value)
      end
      yield self if block_given?
      apply_default_attributes
    end

    # given a soap response hash, initialize a record
    # and ensure they aren't dirty records.
    def self.generate(soap_hash, type)
      result = soap_hash[type][:result]
      return [] if result[:records] == nil
      if result[:size].to_i == 1
        [(new parse_attributes(type, result[:records])).clear_changed_attributes!]
      else
        result[:records].map do |record|
          (new parse_attributes(type, record)).clear_changed_attributes!
        end
      end
    end

    # Remove empty attributes from response hash
    # and typecast any known types from the wsdl
    def self.parse_attributes(type, attrs={})
      # after quite a bit of upstream work, savon
      # still doesn't support using wsdl response
      # definitions, and only handles inline types.
      # This is a work in progress, and hopefully this
      # can be removed in the future via proper support.
      tdefs = Zuora::Api.instance.client.wsdl.type_definitions
      klass = attrs['@xsi:type'.to_sym].base_name
      if klass
        attrs.each do |a,v|
          ref = a.to_s.camelcase
          z = tdefs.find{|d| d[0] == [klass, ref] }
          if z
            case z[1]
            when 'integer', 'int' then
              attrs[a] = v.nil? ? nil : v.to_i
            when 'decimal' then
              attrs[a] = v.nil? ? nil : BigDecimal(v.to_s)
            when 'float', 'double' then
              attrs[a] = v.nil? ? nil : v.to_f
            end
          end
        end
      end
      #remove unknown attributes
      available = attributes.map(&:to_sym)
      attrs.delete_if {|k,v| !available.include?(k) }
    end

    # find a record by the id
    def self.find(id)
      where(:id => id).first
    end

    # reload the record from the remote source
    def reload!
      self.class.find(id).attributes.each{|k,v|
        self.send("#{k}=", v)
      }
      @previously_changed = changes
      @changed_attributes.clear
      self
    end

    def self.unselectable_attributes
      class_variable_get(:@@complex_attributes).keys +
      class_variable_get(:@@write_only_attributes) +
      class_variable_get(:@@deferred_attributes)
    end

    def self.namespace(uri)
      Zuora::Api.instance.client.soap.namespace_by_uri(uri)
    end

    def self.zns
      namespace('http://api.zuora.com/')
    end

    def zns
      self.class.zns
    end

    def self.ons
      namespace('http://object.api.zuora.com/')
    end

    def ons
      self.class.ons
    end

    # locate objects using a custom where clause, currently arel
    # is not supported as it requires an actual db connection to
    # generate the sql queries. This may be overcome in the future.
    def self.where(where)
      keys = (attributes - unselectable_attributes).map(&:to_s).map(&:camelcase)
      if where.is_a?(Hash)
        # FIXME: improper inject usage.
        where = where.inject([]){|t,v| t << "#{v[0].to_s.camelcase} = '#{v[1]}'"}.sort.join(' and ')
      end
      sql = "select #{keys.join(', ')} from #{remote_name} where #{where}"
      result = Zuora::Api.instance.request(:query) do |xml|
        xml.__send__(zns, :queryString, sql)
      end
      generate(result.to_hash, :query_response)
    end

    # has this record not been saved?
    def new_record?
      id.nil?
    end

    # has this record been persisted?
    def persisted?
      !new_record?
    end

    # save the record by updating or creating the record.
    def save
      return false unless valid?
      !!(new_record? ? create : update)
    end

    def save!
      raise StandardError.new(self.errors.map.inspect) unless save
    end

    # create the record remotely
    def create
      result = Zuora::Api.instance.request(:create) do |xml|
        xml.__send__(zns, :zObjects, 'xsi:type' => "#{ons}:#{remote_name}") do |a|
          self.to_hash.each do |k,v|
            a.__send__(ons, k.to_s.camelize.to_sym, v) unless v.nil?
          end
          generate_complex_objects(a, :create)
        end
      end
      apply_response(result.to_hash, :create_response)
    end

    def update
      result = Zuora::Api.instance.request(:update) do |xml|
        xml.__send__(zns, :zObjects, 'xsi:type' => "#{ons}:#{remote_name}") do |a|
          obj_attrs = self.to_hash
          obj_id = obj_attrs.delete(:id)
          a.__send__(ons, :Id, obj_id)
          change_syms = changed.map(&:to_sym)
          obj_attrs.reject{|k,v| read_only_attributes.include?(k) }.each do |k,v|
            a.__send__(ons, k.to_s.camelize.to_sym, v) if change_syms.include?(k)
          end
          generate_complex_objects(a, :update)
        end
      end
      result = apply_response(result.to_hash, :update_response)
      reset_complex_object_cache
      return result
    end

    # destroy the remote object
    def destroy
      result = Zuora::Api.instance.request(:delete) do |xml|
        xml.__send__(zns, :type, remote_name)
        xml.__send__(zns, :ids, id)
      end
      apply_response(result.to_hash, :delete_response)
    end

    protected

    # generate complex objects for inclusion when creating and updating records
    def generate_complex_objects(builder, action)
      complex_attributes.each do |var, scope|
        scope_element = scope.to_s.singularize.classify.to_sym
        var_element = var.to_s.classify.pluralize.to_sym
        builder.__send__(ons, var_element) do |td|
          self.send(scope).each do |object|
            td.__send__(zns, scope_element, 'xsi:type' => "#{ons}:#{scope_element}") do
              case action
              when :create
                object.to_hash.each do |k,v|
                  td.__send__(ons, k.to_s.camelize.to_sym, v) unless v.nil?
                end
              when :update
                object.to_hash.reject{|k,v| object.read_only_attributes.include?(k) || object.restrain_attributes.include?(k) }.each do |k,v|
                  td.__send__(ons, k.to_s.camelize.to_sym, v) unless v.nil?
                end
              end
            end
          end
        end
      end
    end

    # When remote data is loaded, remove the locally cached version of the
    # complex objects so that they may be cleanly reloaded on demand.
    def reset_complex_object_cache
      complex_attributes.invert.keys.each{|k| instance_variable_set("@#{k}_cached", false) }
    end

    # to handle new objects with defaults, we need to make the deafults
    # dirty so that they are passed on create requests.
    def apply_default_attributes
      default_attributes.try(:[], 0).try(:each) do |key, value|
        self.send("#{key}_will_change!")
        self.send("#{key}=", value)
      end
    end

    # parse the response and apply returned id attribute or errors
    def apply_response(response_hash, type)
      result = response_hash[type][:result]
      if result[:success]
        self.id = result[:id]
        @previously_changed = changes
        @changed_attributes.clear
        return true
      else
        self.errors.add(:base, result[:errors][:message])
        return false
      end
    end
  end
end

