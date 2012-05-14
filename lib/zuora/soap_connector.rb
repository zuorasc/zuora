module Zuora
  class SoapConnector
    attr_reader :model
    delegate :ons, :zns, :remote_name, :id, :to => :model

    def initialize(model)
      @model = model
    end

    def query(sql)
      current_client.request(:query) do |xml|
        xml.__send__(@model.zns, :queryString, sql)
      end
    end

    def create
      current_client.request(:create) do |xml|
        xml.__send__(zns, :zObjects, 'xsi:type' => "#{ons}:#{remote_name}") do |a|
          @model.to_hash.each do |k,v|
            a.__send__(ons, k.to_s.camelize.to_sym, v) unless v.nil?
          end
          generate_complex_objects(a, :create)
        end
      end
    end

    def update
      current_client.request(:update) do |xml|
        xml.__send__(zns, :zObjects, 'xsi:type' => "#{ons}:#{remote_name}") do |a|
          obj_attrs = @model.to_hash
          obj_id = obj_attrs.delete(:id)
          a.__send__(ons, :Id, obj_id)
          change_syms = @model.changed.map(&:to_sym)
          obj_attrs.reject{|k,v| @model.read_only_attributes.include?(k) }.each do |k,v|
            a.__send__(ons, k.to_s.camelize.to_sym, v) if change_syms.include?(k)
          end
          generate_complex_objects(a, :update)
        end
      end
    end

    def destroy
      current_client.request(:delete) do |xml|
        xml.__send__(zns, :type, remote_name)
        xml.__send__(zns, :ids, id)
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
      tdefs = current_client.client.wsdl.type_definitions
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
      available = @model.attributes.map(&:to_sym)
      attrs.delete_if {|k,v| !available.include?(k) }
    end

    def current_client
      Zuora::Api.instance
    end

    protected

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
  end
end
