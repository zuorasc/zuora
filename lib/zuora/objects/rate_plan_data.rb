module Zuora::Objects
  class RatePlanData < Base
    attr_accessor :rate_plan

    has_many :rate_plan_charge_data
    belongs_to :amendment

    validates_presence_of :rate_plan

    define_attributes {}
  end
end
