FactoryGirl.define do
  factory :amendment, :class => Zuora::Objects::Amendment do
    contract_effective_date DateTime.now
    service_activation_date DateTime.now
    customer_acceptance_date DateTime.now
    sequence(:name){|n| "Example Amendment #{n}"}
    term_start_date DateTime.now
    type "NewProduct"
    status "Active"
  end
end
