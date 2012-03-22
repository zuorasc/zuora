FactoryGirl.define do
  factory :product_rate_plan_charge, :class => Zuora::Objects::ProductRatePlanCharge do
    association :product_rate_plan
    sequence(:name){|n| "Rate Plan Charge #{n}"}
    bill_cycle_type "DefaultFromCustomer"
    billing_period "Month"
    billing_period_alignment "AlignToCharge"
    charge_model "Volume Pricing"
    charge_type "Recurring"
    included_units "1"
    smoothing_model "Rollover"
    uom "Each"
    trigger_event "ServiceActivation"
    after_build do |prpc|
      prpc.product_rate_plan_charge_tiers << FactoryGirl.build(:product_rate_plan_charge_tier)
    end
  end
end
