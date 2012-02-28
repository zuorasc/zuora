#module Zuora::Objects
  #class Refund < Base
    #belongs_to :account
    #belongs_to :payment
    #belongs_to :payment_method

    #validates_presence_of :amount, :type

    #validates_length_of       :accounting_code, :maximum => 100
    #validates_numericality_of :amount
    #validates_length_of       :comment, :maximum => 255
    #validates_length_of       :created_by_id, :maximum => 32
    #validates_datetime_of     :created_date, :allow_nil => true
    #validates_length_of       :gateway_response, :maximum => 500
    #validates_length_of       :gateway_response_code, :maximum => 20
    #validates_inclusion_of    :method_type, :in => %w(ACH Cash Check CreditCard Other PayPal WireTransfer DebitCard CreditCardReferenceTransaction)
    #validates_length_of       :payment_method_id, :maximum => 60
    #validates_datetime_of     :refund_date
    #validates_datetime_of     :refund_transaction_time, :allow_nil => true
    #validates_length_of       :soft_descriptor, :maximum => 35, :allow_nil => true
    #validates_length_of       :soft_descriptor_phone, :maximum => 20, :allow_nil => true
    #validates_inclusion_of    :source_type, :in => %w(Payment CreditBalance), :allow_nil => true
    #validates_inclusion_of    :status, :in => %w(Canceled Error Processed Processing), :allow_nil => true
    #validates_inclusion_of    :transferred_to_accouning, :allow_nil => true, :in => %w(Processing Yes Error Ignore)
    #validates_inclusion_of    :type, :in => %w(Electronic External)
    #validates_length_of       :updated_by_id, :maximum => 32
    #validates_datetime_of     :update_date, :allow_nil => true

    #define_attributes do
      #read_only :accounting_code, :created_by_id, :created_date, :gateway_response,
        #:gateway_response_code, :reference_id, :refund_number, :refund_transaction_time,
        #:status, :updated_by_id, :updated_date
    #end
  #end
#end
