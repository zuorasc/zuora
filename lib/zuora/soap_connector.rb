module Zuora
  class SoapConnector
    attr_reader :model
    delegate :ons, :zns, :remote_name, :id, :to => :model

    def initialize(model)
      @model = model
    end

    def query(sql)
      Zuora::Api.instance.request(:query) do |xml|
        xml.__send__(@model.zns, :queryString, sql)
      end
    end

    def serialize(xml, key, value)
      if value.kind_of?(Zuora::Objects::Base)
        xml.__send__(zns, key.to_sym) do |child|
          value.to_hash.each do |k, v|
            serialize(child, k.to_s.zuora_camelize, convert_value(v)) unless v.nil?
          end
        end
      else
        xml.__send__(ons, key.to_sym, convert_value(value))
      end
    end

    def create
      Zuora::Api.instance.request(:create) do |xml|
        xml.__send__(zns, :zObjects, 'xsi:type' => "#{ons}:#{remote_name}") do |a|
          @model.to_hash.each do |k,v|
            serialize(a, k.to_s.zuora_camelize.to_sym, convert_value(v)) unless v.nil?
          end
          generate_complex_objects(a, :create)
        end
      end
    end

    def update
      Zuora::Api.instance.request(:update) do |xml|
        xml.__send__(zns, :zObjects, 'xsi:type' => "#{ons}:#{remote_name}") do |a|
          obj_attrs = @model.to_hash
          obj_id = obj_attrs.delete(:id)
          a.__send__(ons, :Id, obj_id)
          change_syms = @model.changed.map(&:to_sym)
          obj_attrs.reject{|k,v| @model.read_only_attributes.include?(k) }.each do |k,v|
            a.__send__(ons, k.to_s.zuora_camelize.to_sym, convert_value(v)) if change_syms.include?(k)
          end
          generate_complex_objects(a, :update)
        end
      end
    end

    def destroy
      Zuora::Api.instance.request(:delete) do |xml|
        xml.__send__(zns, :type, remote_name)
        xml.__send__(zns, :ids, id)
      end
    end

    def amend(action: :create)
      Zuora::Api.instance.request(:amend) do |xml|
        xml.__send__(zns, :requests) do |r|
          r.__send__(zns, :Amendments) do |a|
            @model.to_hash.each do |k,v|
              serialize(a, k.to_s.zuora_camelize.to_sym, convert_value(v)) unless v.nil?
            end
            generate_complex_objects(a, action)
          end
        end
      end
    end

    # Remove empty attributes from response hash
    # and typecast any known types from the wsdl
    def parse_attributes(type, attrs={})
      # after quite a bit of upstream work, savon
      # still doesn't support using wsdl response
      # definitions, and only handles inline types.
      # This is a work in progress, and hopefully this
      # can be removed in the future via proper support.
      tdefs = Zuora::Api.instance.wsdl.type_definitions
      klass = attrs['@xsi:type'.to_sym].base_name
      if klass
        attrs.each do |a,v|
          ref = a.to_s.zuora_camelize
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
      available = @model.attributes.map(&:to_sym)
      attrs.delete_if {|k,v| !available.include?(k) }
    end

    def generate
      Zuora::Api.instance.request(:generate) do |xml|
        xml.__send__(zns, :zObjects, 'xsi:type' => "#{ons}:#{remote_name}") do |a|
          @model.to_hash.each do |k, v|
            a.__send__(ons, k.to_s.zuora_camelize.to_sym, convert_value(v)) unless v.nil?
          end
        end
      end
    end

    protected

    # Zuora doesn't like the default string format of ruby dates/times
    def convert_value(value)
      if [Time, DateTime].any? { |klass| value.is_a?(klass) }
        value.strftime('%FT%T')
      elsif value.is_a?(Date)
        value.strftime('%F')
      else
        value
      end
    end
 
    # generate complex objects for inclusion when creating and updating records
    def generate_complex_objects(builder, action)
      @model.complex_attributes.each do |var, scope|
        scope_element = scope.to_s.singularize.classify.to_sym
        var_element = var.to_s.classify.pluralize.to_sym
        builder.__send__(ons, var_element) do |td|
          @model.send(scope).each do |object|
            td.__send__(zns, scope_element, 'xsi:type' => "#{ons}:#{scope_element}") do
              case action
              when :create
                object.to_hash.each do |k,v|
                  td.__send__(ons, k.to_s.zuora_camelize.to_sym, v) unless v.nil?
                end
              when :update
                object.to_hash.reject{|k,v| object.read_only_attributes.include?(k) ||
                                            object.restrain_attributes.include?(k) }.each do |k,v|
                  td.__send__(ons, k.to_s.zuora_camelize.to_sym, v) unless v.nil?
                end
              end
            end
          end
        end
      end
    end
  end
end
