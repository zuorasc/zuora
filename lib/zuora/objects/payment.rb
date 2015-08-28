module Zuora::Objects
  class Payment < Base
    belongs_to :account
    belongs_to :invoice

    validates_presence_of :account_id, :amount, :effective_date,
     :payment_method_id, :status, :type

    validates_numericality_of :applied_credit_balance_amount, :if =>
      Proc.new { |payment| payment.new_record? && payment.applied_invoice_amount.nil? }

    validates_length_of :accounting_code, :maximum => 100, :allow_nil => true
    validates_numericality_of :amount
    validates_numericality_of :applied_invoice_amount
    validates_length_of :auth_transaction_id, :maximum => 50, :allow_nil => true
    validates_length_of :bank_identification_number, :maximum => 6, :allow_nil => true
    validates_date_of :cancelled_on, :allow_nil => true
    validates_length_of :comment, :maximum => 255, :allow_nil => true
    validates_length_of :created_by_id, :maximum => 32, :allow_nil => true
    validates_date_of :effective_date
    validates_length_of :gateway_order_id, :maximum => 70, :allow_nil => true
    validates_inclusion_of :gateway_state, :in => %w(NotSubmitted Submitted Settled MarkedForSubmission), :allow_nil => true
    validates_datetime_of :marked_for_submission_on, :allow_nil => true
    validates_length_of :payment_number, :maximum => 32, :allow_nil => true
    validates_length_of :reference_id, :maximum => 30, :allow_nil => true
    validates_numericality_of :refund_amount, :allow_nil => true
    validates_length_of :second_payment_reference_id, :maximum => 60, :allow_nil => true
    validates_date_of :settled_on, :allow_nil => true
    validates_length_of :soft_descriptor, :maximum => 35, :allow_nil => true
    validates_length_of :soft_descriptor_phone, :maximum => 20, :allow_nil => true
    validates_inclusion_of :status, :in => %w(Canceled Draft Error Posted Processing Processed Voided)
    validates_date_of :submitted_on, :allow_nil => true
    validates_inclusion_of :transferred_to_accounting, :allow_nil => true, :in => %w(Processing Yes Error Ignore)
    validates_inclusion_of :type, :in => %w(External Electronic)
    validates_length_of :updated_by_id, :maximum => 32
    validates_datetime_of :updated_date, :allow_nil => true

    define_attributes do
     read_only :bank_identification_number, :created_by_id, :created_date, :gateway_response,
       :gateway_response_code, :updated_by_id, :updated_date, :gateway_state
     write_only :applied_invoice_amount, :bank_identification_number, :gateway_option_data,
       :invoice_id, :invoice_number
      defer :invoice_payment_data
    end
  end
end
