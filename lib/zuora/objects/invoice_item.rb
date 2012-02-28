module Zuora::Objects
  class InvoiceItem < Base
    belongs_to :invoice
    belongs_to :product
    belongs_to :rate_plan_charge
    belongs_to :subscription

    validates_presence_of :charge_amount, :charge_date, :charge_number, :invoice_id, :product_id,
      :product_name, :rate_plan_charge_id, :service_start_date, :subscription_id, :unit_price

    validates_length_of :accounting_code, :maximum => 255, :allow_nil => true
    validates_numericality_of :charge_amount
    validates_datetime_of :charge_date
    validates_length_of :charge_name, :maximum => 50, :allow_nil => true
    validates_length_of :created_by_id, :maximum => 32, :allow_nil => true
    validates_inclusion_of :processing_type, :in => [0,1,2,3], :allow_nil => true
    validates_length_of :product_description, :maximum => 255, :allow_nil => true
    validates_length_of :product_name, :maximum => 255
    validates_numericality_of :quantity, :allow_nil => true
    validates_length_of :rev_rec_code, :maximum => 70
    validates_datetime_of :rev_rec_start_date, :allow_nil => true
    validates_datetime_of :service_end_date, :allow_nil => true
    validates_datetime_of :service_start_date
    validates_length_of :sku, :maximum => 255
    validates_numericality_of :unit_price
    validates_length_of :uom, :maximum => 255
    validates_length_of :updated_by_id, :maximum => 32

    define_attributes do
      read_only :charge_description, :charge_name, :charge_number, :created_by_id, :created_date,
        :invoice_id, :product_description, :quantity, :subscription_number,
        :updated_by_id, :updated_date
    end
  end
end
