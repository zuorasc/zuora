module Zuora::Objects
  # All Zuora objects extend from Zuora::Objects::Base, which provide the fundemental requirements
  # for handling creating, destroying, updating, and querying Zuora.
  class Base
    include Zuora::Attributes
    include Zuora::Validations
    include Zuora::Associations

    # generate a new instance of a Zuora object
    def initialize(attrs={}, &block)
      apply_default_attributes
      self.attributes = attrs
      yield self if block_given?
    end

    def attributes=(attrs={})
      attrs.each do |name, value|
        self.send("#{name.to_s.underscore}=", value)
      end
    end

    # given a soap response hash, initialize a record
    # and ensure they aren't dirty records.
    def self.generate(soap_hash, type)
      result = soap_hash[type][:result]
      return [] if result[:records] == nil
      if result[:size].to_i == 1
        [(new self.connector.parse_attributes(type, result[:records])).clear_changed_attributes!]
      else
        result[:records].map do |record|
          (new self.connector.parse_attributes(type, record)).clear_changed_attributes!
        end
      end
    end
    # get all the records
    def self.all
      keys = (attributes - unselectable_attributes).map(&:to_s).map(&:zuora_camelize)
      sql = "select #{keys.join(', ')} from #{remote_name}"

      result = self.connector.query(sql)

      generate(result.to_hash, :query_response)
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
      Zuora::Api.instance.client.operation(:query).build.send(:namespace_by_uri, uri)
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
      keys = (attributes - unselectable_attributes).map(&:to_s).map(&:zuora_camelize)
      if where.is_a?(Hash)
        # FIXME: improper inject usage.
        where = where.inject([]){|t,v| t << "#{v[0].to_s.zuora_camelize} = '#{v[1]}'"}.sort.join(' and ')
      end
      sql = "select #{keys.join(', ')} from #{remote_name} where #{where}"

      result = self.connector.query(sql)

      generate(result.to_hash, :query_response)
    end

    def self.query(query_string)
      result = self.connector.query(query_string)
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
      result = self.connector.create
      apply_response(result.to_hash, :create_response)
    end

    def update
      result = self.connector.update
      result = apply_response(result.to_hash, :update_response)
      reset_complex_object_cache
      return result
    end

    # destroy the remote object
    def destroy
      result = self.connector.destroy
      apply_response(result.to_hash, :delete_response)
    end

    def self.connector_class
      @@connector_class ||= Zuora::SoapConnector
    end

    def self.connector_class=(connector)
      @@connector_class = connector
    end

    def self.connector
      self.connector_class.new(self)
    end

    def connector
      self.class.connector_class.new(self)
    end

    protected

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

