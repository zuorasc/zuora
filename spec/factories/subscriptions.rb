FactoryGirl.define do
  factory :subscription, :class => Zuora::Objects::Subscription do
    contract_effective_date Date.today
    sequence(:name){|n| "Example Subscription #{n}"}
    term_start_date DateTime.now
  end
end
