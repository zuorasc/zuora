Factory.define :account, :class => Zuora::Objects::Account do |f|
  f.sequence(:name){|n| "Test Account #{n}"}
  f.sequence(:account_number){|n| "test_account_#{n}" }
end

Factory.define :active_account, :parent => :account do |f|
  f.after_create do |account|
    contact = Factory.create(:contact, :account => account)
    account.bill_to = contact
    account.sold_to = contact
    account.status = "Active"
    account.save
  end
end

