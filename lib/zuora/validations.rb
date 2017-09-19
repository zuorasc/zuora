module Zuora
  module Validations

    def self.included(base)
      base.send(:include, ActiveModel::Validations)
      base.extend(ClassMethods)
    end

    class DateTimeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        unless [DateTime, Time].any? { |klass| value.is_a?(klass) }
          record.errors[attribute] << (options[:message] || "is not a valid datetime")
        end
      end
    end

    class DateValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        unless [Date].any? { |klass| value.is_a?(klass) }
          record.errors[attribute] << (options[:message] || "is not a valid date")
        end
      end
    end

    module ClassMethods
      def validates_datetime_of(*attr_names)
        options = attr_names.extract_options!
        attr_names.each do |attr_name|
          validates attr_name, {:date_time => true}.merge(options)
        end
      end

      def validates_date_of(*attr_names)
        options = attr_names.extract_options!
        attr_names.each do |attr_name|
          validates attr_name, {:date => true}.merge(options)
        end
      end
    end
  end
end
