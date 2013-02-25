module Zuora::Objects
  class Account < Base
    has_many :contacts
    has_many :payment_methods
    has_many :subscriptions
    has_many :invoices
    belongs_to :bill_to, :class_name => 'Contact'
    belongs_to :sold_to, :class_name => 'Contact'

    validates_presence_of :account_number, :name, :status, :payment_term, :batch, :currency
    validates_length_of :name, :maximum => 50
    validates_length_of :purchase_order_number, :maximum => 100, :allow_nil => true
    validates_inclusion_of :payment_term, :in => ['Due Upon Receipt','Net 30','Net 45','Net 90']
    validates_inclusion_of :batch, :in => (1..20).map{|n| "Batch#{n}" }
    validates_inclusion_of :bcd_setting_option, :in => ['AutoSet','ManualSet'], :allow_nil => true
    validates_inclusion_of :bill_cycle_day, :in => (1..31).to_a + (1..31).map(&:to_s)
    validates_inclusion_of :status, :in => ['Draft','Active','Canceled'], :allow_nil => true

    define_attributes do
      read_only :balance, :created_date, :credit_balance, :last_invoice_date,
                :parent_id, :total_invoice_balance, :updated_date,
                :created_by_id, :last_invoice_date, :updated_by_id

      defaults :auto_pay => false,
               :currency => 'USD',
               :batch => 'Batch1',
               :bill_cycle_day => 1,
               :status => 'Draft',
               :payment_term => 'Due Upon Receipt'
    end
  end
end

