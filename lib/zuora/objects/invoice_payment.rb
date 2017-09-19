module Zuora::Objects
  class InvoicePayment < Base
    belongs_to :invoice
    belongs_to :payment

    validates_presence_of :amount, :invoice_id, :payment_id
    validates_numericality_of :amount
    validates_length_of :created_by_id, :maximum => 32
    # validates_datetime_of :created_date, :allow_nil => true
    validates_numericality_of :refund_amount
    validates_length_of :updated_by_id, :maximum => 32
    # validates_datetime_of :update_date, :allow_nil => true

    define_attributes do
      read_only :created_by_id, :created_date, :updated_by_id, :updated_date
    end
  end
end
