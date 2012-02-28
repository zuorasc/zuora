#module Zuora::Objects
  #class RefundInvoicePayment < Base
    #belongs_to :invoice_payment
    #belongs_to :refund

    #validates_presence_of :invoice_payment_id, :refund_amount, :refund_id

    #validates_length_of   :created_by_id, :maximum => 32
    #validates_datetime_of :created_date, :allow_nil => true
    #validates_length_of   :updated_by_id, :maximum => 32
    #validates_datetime_of :update_date, :allow_nil => true

    #define_attributes do
      #read_only :created_by_id, :created_date, :invoice_payment_id, :refund_amount,
        #:refund_id, :updated_by_id, :updated_date
    #end
  #end
#end
