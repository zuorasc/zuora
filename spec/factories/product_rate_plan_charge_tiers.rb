FactoryGirl.define do
  factory :product_rate_plan_charge_tier, :class => Zuora::Objects::ProductRatePlanChargeTier do
    price 0
    starting_unit 0
    ending_unit 10
  end
end
