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

    def subscribe
      current_client.request(:subscribe) do |xml|
        xml.__send__(zns, :subscribes) do |s|
          s.__send__(zns, :Account) do |a|
            generate_account(a)
          end

          s.__send__(zns, :PaymentMethod) do |pm|
            generate_payment_method(pm)
          end unless @model.payment_method.nil?

          s.__send__(zns, :BillToContact) do |btc|
            generate_bill_to_contact(btc)
          end unless @model.bill_to_contact.nil?

          s.__send__(zns, :SoldToContact) do |btc|
            generate_sold_to_contact(btc)
          end unless @model.sold_to_contact.nil?

          s.__send__(zns, :SubscribeOptions) do |so|
            generate_subscribe_options(so)
          end unless @model.subscribe_options.blank?

          s.__send__(zns, :SubscriptionData) do |sd|
            sd.__send__(zns, :Subscription) do |sub|
              generate_subscription(sub)
            end

            sd.__send__(zns, :RatePlanData) do |rpd|
              rpd.__send__(zns, :RatePlan) do |rp|
                rp.__send__(ons, :ProductRatePlanId, @model.product_rate_plan.id)
              end
            end
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

    def generate_bill_to_contact(builder)
      if @model.bill_to_contact.new_record?
        @model.bill_to_contact.to_hash.each do |k,v|
          builder.__send__(ons, k.to_s.camelize.to_sym, v) unless v.nil?
        end
      else
        builder.__send__(ons, :Id, @model.bill_to_contact.id)
      end
    end

    def generate_sold_to_contact(builder)
      if @model.sold_to_contact.new_record?
        @model.sold_to_contact.to_hash.each do |k,v|
          builder.__send__(ons, k.to_s.camelize.to_sym, v) unless v.nil?
        end
      else
        builder.__send__(ons, :Id, @model.sold_to_contact.id)
      end
    end

    def generate_account(builder)
      if @model.account.new_record?
        @model.account.to_hash.each do |k,v|
          builder.__send__(ons, k.to_s.camelize.to_sym, v) unless v.nil?
        end
      else
        builder.__send__(ons, :Id, @model.account.id)
      end
    end

    def generate_payment_method(builder)
      if @model.payment_method.new_record?
        @model.payment_method.to_hash.each do |k,v|
          builder.__send__(ons, k.to_s.camelize.to_sym, v) unless v.nil?
        end
      else
        builder.__send__(ons, :Id, @model.payment_method.id)
      end
    end

    def generate_subscription(builder)
      @model.subscription.to_hash.each do |k,v|
        builder.__send__(ons, k.to_s.camelize.to_sym, v) unless v.nil?
      end
    end

    def generate_subscribe_options(builder)
      @model.subscribe_options.each do |k,v|
        builder.__send__(zns, k.to_s.camelize.to_sym, v)
      end
    end

  end
end
