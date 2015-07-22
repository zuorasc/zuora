module Zuora::Objects
  class Subscription < Base
    belongs_to :account
    belongs_to :ancestor_account, :class_name => 'Account'
    belongs_to :creator_account, :class_name => 'Account'
    belongs_to :creator_invoice_owner, :class_name => 'Account'
    has_many :rate_plans

    validates_presence_of :contract_effective_date, :initial_term,
                          :renewal_term, :term_start_date

    validates_inclusion_of    :auto_renew, :in => [true, false]
    validates_datetime_of     :cancelled_date, :allow_nil => true
    validates_datetime_of     :contract_acceptance_date, :allow_nil => true
    validates_datetime_of     :contract_effective_date
    validates_numericality_of :initial_term, :only_integer => true, :minimum => 1
    validates_inclusion_of    :is_invoice_separate, :in => [true, false], :allow_nil => true
    validates_length_of       :name, :maximum => 100
    validates_length_of       :notes, :maximum => 500, :allow_nil => true
    validates_datetime_of     :original_created_date, :allow_nil => true
    validates_numericality_of :renewal_term, :only_integer => true
    validates_datetime_of     :service_activation_date, :allow_nil => true
    validates_datetime_of     :term_end_date, :allow_nil => true
    validates_datetime_of     :term_start_date
    validates_inclusion_of    :term_type, :in => ['TERMED', 'EVERGREEN'], :allow_nil => true

    define_attributes do

      read_only :created_by_id, :created_date, :updated_by_id, :updated_date, :cancelled_date,
        :original_created_date, :original_id, :previous_subscription_id, :status,
        :subscription_end_date, :term_end_date, :version, :subscription_start_date

      defaults :auto_renew          => false,
               :initial_term        => 1,
               :is_invoice_separate => false,
               :renewal_term        => 0

      defer :ancestor_account_id
    end
  end
end
