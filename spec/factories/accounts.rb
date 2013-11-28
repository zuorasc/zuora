FactoryGirl.define do
  factory :account, :class => Zuora::Objects::Account do
    sequence(:name){|n| "Test Account #{n}"}
    sequence(:account_number){|n| "test_account_#{n}" }
  end

  factory :active_account, :parent => :account do
    after_create do |account|
      contact = FactoryGirl.create(:contact, :account => account, :country => "GB")
      account.bill_to = contact
      account.sold_to = contact
      account.status = "Active"
      account.save
    end
  end
end
