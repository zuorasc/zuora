Factory.define :product_rate_plan_charge_tier, :class => Zuora::Objects::ProductRatePlanChargeTier do |f|
  f.price 0
  f.active true
  f.starting_unit 0
  f.ending_unit 10
end

