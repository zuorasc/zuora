Factory.define :product_rate_plan, :class => Zuora::Objects::ProductRatePlan do |f|
  f.sequence(:name){|n| "Rate Plan #{n}"}
  f.association :product
  f.effective_start_date DateTime.now
  f.effective_end_date   DateTime.now + 10.days
end

