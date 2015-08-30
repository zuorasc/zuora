module Zuora::Objects
  class ProductRatePlan < Base
    belongs_to :product
    has_many :product_rate_plan_charges

    validates_length_of :description, :maximum => 500, :allow_nil => true
    validates_datetime_of :effective_start_date, :effective_end_date
    validates_length_of :name, :maximum => 100, :allow_nil => true

    define_attributes do
      read_only :updated_by_id, :updated_date, :created_by_id, :created_date
      defer :active_currencies
    end
  end
end
