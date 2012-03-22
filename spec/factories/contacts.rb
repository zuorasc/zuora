FactoryGirl.define do
  factory :contact, :class => Zuora::Objects::Contact do
    first_name "Example"
    sequence(:last_name){|n| "User #{n}" }
  end
end
