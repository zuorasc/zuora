module Zuora::Objects
  class CreditBalanceAdjustment < Base
    belongs_to :account
    belongs_to :source_transaction

    validates_length_of :accounting_code, :maximum => 100, :allow_nil => true
    validates_presence_of :account_id
    validates_numericality_of :amount
    validates_length_of :comment, :maximum => 255, :allow_nil => true
    validates_length_of :reference_id, :maximum => 60, :allow_nil => true
    validates_presence_of :source_transaction_id, :if => Proc.new { |c| c.source_transaction_type == 'Adjustment' }
    validates_inclusion_of :source_transaction_type, :in => %w(Invoice Payment Refund Adjustment), :unless => :source_transaction
    validates_length_of :source_transaction_number, :maximum => 50, :if => Proc.new { |c| c.source_transaction_type == 'Adjustment' && !c.source_transaction }
    validates_inclusion_of :transferred_to_accounting, :in => %w(Processing Yes Error Ignore), :allow_nil => true
    validates_inclusion_of :type, :in => %w(Increase Decrease)

    define_attributes do
      read_only :created_by_id, :created_date, :updated_by_id, :updated_date
    end
  end
end
