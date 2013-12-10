module Zuora::Objects
  class RatePlanChargeData < Base
    attr_accessor :rate_plan_charge

    has_many :rate_plan_charge_tiers
    belongs_to :rate_plan_data

    validates_presence_of :rate_plan_charge

    define_attributes {}
  end
end
