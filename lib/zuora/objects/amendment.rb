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
    validates_presence_of :rate_plan_data, :if => Proc.new { |a| ['NewProduct', 'RemoveProduct', 'UpdateProduct'].include?(a.type) }

    attr_accessor :amendment_ids
    attr_accessor :invoice_id
    attr_accessor :payment_transaction_number

    define_attributes do
      read_only :created_by_id, :created_date, :updated_by_id, :updated_date, :amendment_ids, :invoice_id, :payment_transaction_number
      defaults :status => 'Draft'
    end

    def create
      result = self.connector.amend
      apply_response(result.to_hash, :amend_response)
    end

    def apply_response(response_hash, type)
      result = response_hash[type][:results]
      if result[:success]
        self.amendment_ids = result[:amendment_ids]
        self.invoice_id = result[:invoice_id]
        self.payment_transaction_number = result[:payment_transaction_number]
        @previously_changed = changes
        @changed_attributes.clear
        return true
      else
        self.errors.add(:base, result[:errors][:message])
        return false
      end
    end
  end
end
