module Zuora
  module Attributes
    def self.included(base)
      base.send(:include, ActiveModel::Naming)
      base.send(:include, ActiveModel::Conversion)
      base.send(:include, ActiveModel::Dirty)
      base.extend ClassMethods
    end

    module ClassMethods
      # Due to limitations of setting up attributes via the WSDL when
      # inherited, attribute definition is defined in a block format
      # so that the attributes are available and multiple decorators
      # can be applied to those attributes.
      def define_attributes(&block)
        yield self
        class_variable_get(:@@wsdl_attributes).each do |attr|
          class_eval <<-EVAL
            @@all_attributes << "#{attr}".to_sym

            define_method "#{attr}" do
              @#{attr}
            end

            define_method "#{attr}?" do
              #{attr} ? true : false
            end

            # writable attributes with dirty support
            define_method "#{attr}=" do |value|
              return if value == @#{attr}

              #{attr}_will_change!
              @#{attr} = value
            end
          EVAL
        end

        # generate association overrides for complex object handling
        # and cache the objects so that they may be modified and updated
        class_variable_get(:@@complex_attributes).each do |var, scope|
          # set up the instance variable for the new assoc collection
          # for new records, but call the original one for existing
          # records and cache/return the result for subsequent calls.
          class_eval <<-EVAL
            def #{scope}_with_complex
              if new_record? || @#{scope}_cached
                @#{scope} ||= []
              else
                @#{scope}_cached = true
                @#{scope} = #{scope}_without_complex
              end
            end
            alias_method_chain :#{scope}, :complex
          EVAL
        end
      end

      # Store attr_accessor and their values
      def store_accessors(storage_name)
        class_eval <<-EVAL, __FILE__, __LINE__ + 1
          define_method "#{storage_name}" do
            @#{storage_name} ||= {}
          end

          define_method "#{storage_name}=" do |value|
            @#{storage_name} = value
          end

          def attr_accessor(attribute)
            super

            define_method "\#{attribute}=" do |value|
              #{storage_name}[attribute] = value
              @@all_attributes << attribute.to_sym
              super
            end
          end
        EVAL
      end

      # define read only attributes which will not be sent
      # to the server when making update and create requests.
      def read_only(*args)
        class_variable_set(:@@read_only_attributes, args)
      end
      alias_method :read_only_attributes, :read_only

      # self evident?
      def write_only(*args)
        class_variable_set(:@@write_only_attributes, args)
      end
      alias_method :write_only_attributes, :write_only

      def defer(*args)
        class_variable_set(:@@deferred_attributes, args)
      end
      alias_method :deferred_attributes, :defer

      # alias to support a cleaner DSL for generating custom fattrs
      # and tracking the default attributes for dirty support
      def defaults(*args)
        class_variable_set(:@@default_attributes, args)
      end
      alias_method :default_attributes, :defaults

      # remove complex objects from the attributes as they should
      # be handled via associations instead being queried when
      # making remote query requests.
      def complex(*args)
        class_variable_set(:@@complex_attributes, *args)
        attrs = class_variable_get(:@@wsdl_attributes)
        class_variable_set(:@@wsdl_attributes, attrs - args)
      end
      alias_method :complex_attributes, :complex

      # store restrained attributes so they aren't sent on updates
      # TODO: rename to create_only as this is more obvious
      def restrain(*args)
        class_variable_set(:@@restrain_attributes, args)
      end
      alias_method :restrain_attributes, :restrain

      def attributes
        class_variable_get(:@@all_attributes).map(&:to_sym)
      end

      # the name to use when referencing remote Zuora objects
      def remote_name
        self.name.base_name
      end

      # All Zuora::Objects::Base inherited objects will have their attributes automatically
      # generated from the provided WSDL.
      def inherited(subclass)
        super
        xpath = "//xs:complexType[@name='#{subclass.remote_name}']//xs:sequence/xs:element"
        document = Zuora::Api.instance.wsdl.parser.instance_variable_get('@document')
        q = document.xpath(xpath, 's0' => 'http://schemas.xmlsoap.org/wsdl/', 'xs' => 'http://www.w3.org/2001/XMLSchema')
        wsdl_attrs = (q.map{|e| e.attributes['name'].value.underscore.to_sym }) << :id
        subclass.send(:class_variable_set, :@@wsdl_attributes,  wsdl_attrs)
        subclass.send(:class_variable_set, :@@read_only_attributes, [])
        subclass.send(:class_variable_set, :@@default_attributes, {})
        subclass.send(:class_variable_set, :@@complex_attributes, {})
        subclass.send(:class_variable_set, :@@restrain_attributes, [])
        subclass.send(:class_variable_set, :@@write_only_attributes, [])
        subclass.send(:class_variable_set, :@@deferred_attributes, [])
        subclass.send(:class_variable_set, :@@all_attributes, [])

        subclass.send(:define_attribute_methods, wsdl_attrs)
      end
    end

    # returns an array of symbols for all read only attributes.
    def read_only_attributes
      return [] unless self.class.class_variable_defined?(:@@read_only_attributes)
      self.class.send(:class_variable_get, :@@read_only_attributes)
    end

    # returns an array of symbols for all write only attributes.
    def write_only_attributes
      return [] unless self.class.class_variable_defined?(:@@write_only_attributes)
      self.class.send(:class_variable_get, :@@write_only_attributes)
    end

    # returns an array of symbols for all attributes read from WSDL.
    def wsdl_attributes
      return [] unless self.class.class_variable_defined?(:@@wsdl_attributes)
      self.class.send(:class_variable_get, :@@wsdl_attributes)
    end

    # attributes with a default value
    def default_attributes
      return [] unless self.class.class_variable_defined?(:@@default_attributes)
      self.class.send(:class_variable_get, :@@default_attributes)
    end

    # complex attribute mapping
    def complex_attributes
      return [] unless self.class.class_variable_defined?(:@@complex_attributes)
      self.class.send(:class_variable_get, :@@complex_attributes)
    end

    # attribute keys which can only be created but not updated
    def restrain_attributes
      return [] unless self.class.class_variable_defined?(:@@restrain_attributes)
      self.class.send(:class_variable_get, :@@restrain_attributes)
    end

    # attribute keys which are ignored by default
    def deferred_attributes
      return [] unless self.class.class_variable_defined?(:@@deferred_attributes)
      self.class.send(:class_variable_get, :@@deferred_attributes)
    end

    # a hash representation of all attributes including their values
    def attributes
      self.class.attributes.inject({}){|h,a| h.update a.to_sym => send(a)}
    end
    alias_method :to_hash, :attributes

    # remove all dirty tracking for the object and return self for chaining.
    def clear_changed_attributes!
      @changed_attributes = {}
      self
    end

    # the name to use when referencing remote Zuora objects
    def remote_name
      self.class.name.base_name
    end
  end
end
