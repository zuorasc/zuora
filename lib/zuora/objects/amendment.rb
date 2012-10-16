module Zuora::Objects
  class Amendment < Base
    belongs_to :subscription

    validates_presence_of :subscription_id, :name
    validates_length_of :name, :maximum => 100
    validates_inclusion_of :auto_renew, :in => [true, false], :allow_nil => true
    validates_length_of :code, :maximum => 50, :allow_nil => true
    validates_datetime_of :contract_effective_date, :allow_nil => true
    validates_datetime_of :customer_acceptance_date, :allow_nil => true
    validates_datetime_of :effective_date, :allow_nil => true
    validates_datetime_of :service_activation_date, :if => Proc.new { |a| a.status == 'PendingAcceptance' }
    validates_length_of :description, :maximum => 500, :allow_nil => true
    validates_numericality_of :initial_term, :if => Proc.new { |a| a.type == 'TermsAndConditions' }
    validates_numericality_of :renewal_term, :if => Proc.new { |a| a.type == 'TermsAndConditions' }
    validates_date_of :term_start_date, :if => Proc.new { |a| a.type == 'TermsAndConditions' }
    validates_presence_of :destination_account_id, :if => Proc.new {|a| a.type == 'OwnerTransfer' }
    validates_presence_of :destination_invoice_owner_id, :if => Proc.new {|a| a.type == 'OwnerTransfer' }
    validates_inclusion_of :status, :in => ["Completed", "Cancelled", "Draft", "Pending Acceptance", "Pending Activation"]
    validates_inclusion_of :term_type, :in => ['TERMED', 'EVERGREEN'], :allow_nil => true
    validates_inclusion_of :type, :in => ['Cancellation', 'NewProduct', 'OwnerTransfer', 'RemoveProduct', 'Renewal', 'UpdateProduct', 'TermsAndConditions']

    define_attributes do
      read_only :created_by_id, :created_date, :updated_by_id, :updated_date
      defaults :status => 'Draft'
      write_only :rate_plan_data
    end
  end
end
