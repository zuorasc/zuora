Factory.define :subscription, :class => Zuora::Objects::Subscription do |f|
  f.contract_effective_date DateTime.now
  f.sequence(:name){|n| "Example Subscription #{n}"}
  f.term_start_date DateTime.now
end
