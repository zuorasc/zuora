module Zuora::Objects
  class RatePlanChargeTier < Base
    belongs_to :rate_plan_charge

    validates_presence_of :price

    validates_inclusion_of :is_overage_price, :in => [true, false,], :allow_nil => true
    validates_inclusion_of :price_format, :in => ['Flat Fee', 'Per Unit',], :allow_nil => true

    # TODO: starting_unit, ending_unit ... not quite.
    validates_numericality_of :starting_unit, :allow_blank => true, :greater_than => 0
    validates_numericality_of :ending_unit, :allow_blank => true, :greater_than => 0
    validates_numericality_of :price, :greater_than => 0
    validates_numericality_of :tier

    define_attributes do
      read_only :created_date, :updated_date, :created_by_id, :updated_by_id, :tier
      restrain :starting_unit, :ending_unit, :is_overage_price, :price_format
    end
  end
end
