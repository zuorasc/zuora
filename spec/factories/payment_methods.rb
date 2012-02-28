Factory.define :payment_method_credit_card, :class => Zuora::Objects::PaymentMethod do |f|
  f.type "CreditCard"
  f.credit_card_address1 "123 Testing Lane"
  f.credit_card_city "San Francisco"
  f.credit_card_state "California"
  f.credit_card_postal_code "95611"
  f.credit_card_holder_name "Example User"
  f.credit_card_number "4111111111111111"
  f.credit_card_type "Visa"
  f.credit_card_expiration_month "9"
  f.credit_card_expiration_year "2018"
end

Factory.define :payment_method_debit_card, :parent => :payment_method_credit_card do |f|
  f.type "DebitCard"
end

Factory.define :payment_method_ach, :class => Zuora::Objects::PaymentMethod do |f|
  f.type "ACH"
  f.ach_aba_code '123456789'
  f.ach_account_name 'My Checking Account'
  f.ach_account_number '987654321'
  f.ach_bank_name 'Bank of Zuora'
  f.ach_account_type 'BusinessChecking'
end

Factory.define :payment_method_paypal, :class => Zuora::Objects::PaymentMethod do |f|
  f.type 'PayPal'
  f.paypal_baid "ExampleBillingAgreementId"
  f.paypal_email "example@example.org"
  f.paypal_type "ExpressCheckout"
end
