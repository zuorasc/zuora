FactoryGirl.define do
  factory :payment_method_credit_card, :class => Zuora::Objects::PaymentMethod do
    type "CreditCard"
    credit_card_address1 "123 Testing Lane"
    credit_card_city "San Francisco"
    credit_card_state "California"
    credit_card_postal_code "95611"
    credit_card_holder_name "Example User"
    credit_card_number "4111111111111111"
    credit_card_type "Visa"
    credit_card_expiration_month "9"
    credit_card_expiration_year "2018"
  end

  factory :payment_method_debit_card, :parent => :payment_method_credit_card do
    type "DebitCard"
  end

  factory :payment_method_ach, :class => Zuora::Objects::PaymentMethod do
    type "ACH"
    ach_aba_code '123456789'
    ach_account_name 'My Checking Account'
    ach_account_number '987654321'
    ach_bank_name 'Bank of Zuora'
    ach_account_type 'BusinessChecking'
  end

  factory :payment_method_paypal, :class => Zuora::Objects::PaymentMethod do
    type 'PayPal'
    paypal_baid "ExampleBillingAgreementId"
    paypal_email "example@example.org"
    paypal_type "ExpressCheckout"
  end
end
