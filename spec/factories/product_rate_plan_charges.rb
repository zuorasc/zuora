Factory.define :product_rate_plan_charge, :class => Zuora::Objects::ProductRatePlanCharge do |f|
  f.association :product_rate_plan
  f.sequence(:name){|n| "Rate Plan Charge #{n}"}
  f.bill_cycle_type "DefaultFromCustomer"
  f.billing_period "Month"
  f.billing_period_alignment "AlignToCharge"
  f.charge_model "Volume Pricing"
  f.charge_type "Recurring"
  f.included_units "1"
  f.smoothing_model "Rollover"
  f.uom "Each"
  f.trigger_event "ServiceActivation"
  f.after_build do |prpc|
    prpc.product_rate_plan_charge_tiers << Factory.build(:product_rate_plan_charge_tier)
  end
end
