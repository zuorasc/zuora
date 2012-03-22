FactoryGirl.define do
  factory :product_rate_plan, :class => Zuora::Objects::ProductRatePlan do
    sequence(:name){|n| "Rate Plan #{n}"}
    association :product
    effective_start_date DateTime.now
    effective_end_date   DateTime.now + 10.days
  end
end
