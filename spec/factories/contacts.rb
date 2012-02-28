Factory.define :contact, :class => Zuora::Objects::Contact do |f|
  f.first_name "Example"
  f.sequence(:last_name){|n| "User #{n}" }
end

