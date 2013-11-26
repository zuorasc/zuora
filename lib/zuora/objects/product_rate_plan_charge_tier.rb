module Zuora::Objects
  class ProductRatePlanChargeTier < Base
    belongs_to :product_rate_plan_charge

    validates_inclusion_of :is_overage_price, :in => [true, false], :allow_nil => true
    validates_inclusion_of :price_format, :in => ['Flat Fee', 'Per Unit'], :allow_nil => true
    validates_numericality_of :price, :greater_than => 0

    define_attributes do
      read_only :created_date, :updated_date, :created_by_id, :updated_by_id, :tier
      restrain :starting_unit, :ending_unit, :is_overage_price, :price_format
    end
  end
end
