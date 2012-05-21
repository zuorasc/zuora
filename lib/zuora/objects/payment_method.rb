module Zuora::Objects
  class PaymentMethod < Base
    belongs_to :account

    # validates_presence_of :account_id

    # Generic Validations
    validates_inclusion_of    :type, :in => %w(ACH BankTransfer Cash Check CreditCard CreditCardReferenceTransaction DebitCard Other PayPal WireTransfer)
    validates_length_of       :device_session_id, :maximum => 255, :allow_nil => true
    validates_length_of       :email, :maximum => 80, :allow_nil => true
    validates_length_of       :ip_address, :maximum => 15, :allow_nil => true
    validates_inclusion_of    :skip_validation, :in => [true, false], :allow_nil => true
    validates_inclusion_of    :use_default_retry_rule, :in => [true, false], :allow_nil => true
    validates_numericality_of :max_consecutive_payment_failures, :integer_only => true, :greater_than_or_equal_to => 0, :unless => :use_default_retry_rule?
    validates_numericality_of :num_consecutive_failures, :integer_only => true, :greater_than_or_equal_to => 0, :allow_nil => true
    validates_numericality_of :payment_retry_window, :integer_only => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 6000, :unless => :use_default_retry_rule?

    # Card Validations
    validates_length_of       :credit_card_address1, :maximum => 255, :allow_nil => true
    validates_length_of       :credit_card_address2, :maximum => 255, :allow_nil => true
    validates_length_of       :credit_card_city, :maximum => 40, :allow_nil => true
    validates_length_of       :credit_card_state, :maximum => 50, :if => :card?
    validates_length_of       :credit_card_postal_code, :maximum => 20, :if => :card?
    validates_length_of       :credit_card_country, :maximum => 40, :allow_nil => true, :if => :card?
    validates_numericality_of :credit_card_expiration_month, :integer_only => true, :within => 1..12, :if => :card?
    validates_numericality_of :credit_card_expiration_year, :integer_only => true, :greater_than => lambda{|e| Date.today.year }, :if => :card?
    validates_length_of       :credit_card_holder_name, :maximum => 50, :if => :card?
    validates_length_of       :credit_card_number, :maximum => 16, :if => :card?
    validates_inclusion_of    :credit_card_type, :in => %w(AmericanExpress Discover MasterCard Visa), :if => :card?
    validates_length_of       :phone, :maximum => 40, :allow_nil => true

    # ACH Validations
    validates_length_of       :ach_aba_code, :maximum => 20, :if => :ach?
    validates_length_of       :ach_account_name, :maximum => 70, :if => :ach?
    validates_length_of       :ach_account_number, :maximum => 50, :if => :ach?
    validates_length_of       :ach_account_number_mask, :maximum => 32, :if => :ach?
    validates_length_of       :ach_bank_name, :maximum => 70, :if => :ach?
    validates_inclusion_of    :ach_account_type, :in => %w(BusinessChecking Checking Saving), :if => :ach?

    # PayPal Validations
    validates_length_of       :paypal_email, :maximum => 80, :if => :paypal?
    validates_inclusion_of    :paypal_type, :in => %w(ExpressCheckout AdaptivePayments), :if => :paypal?
    validates_length_of       :paypal_baid, :maximum => 64, :if => Proc.new {|m| m.paypal? && !m.paypal_preapproval_key? }
    validates_length_of       :paypal_preapproval_key, :maximum => 32, :if => Proc.new {|m| m.paypal? && !m.paypal_baid? }

    define_attributes do
      read_only :ach_account_number_mask, :bank_identification_number, :created_by_id,
        :created_date, :credit_card_mask_number, :last_failed_sale_transaction_date,
        :last_transaction_status, :name, :num_consecutive_failures, :updated_date,
        :total_number_of_error_payments, :total_number_of_processed_payments, :active,
        :bank_city, :bank_name, :bank_postal_code, :bank_street_name,
        :bank_street_number, :bank_transfer_account_type, :last_transaction_datetime,
        :payment_method_status

      write_only :ach_account_number, :credit_card_number, :credit_card_security_code,
        :gateway_option_data, :skip_validation, :bank_transfer_account_number

      default_attributes :use_default_retry_rule => true
    end

    def paypal?
      'PayPal' == type
    end

    def ach?
      'ACH' == type
    end

    def credit_card?
      'CreditCard' == type
    end

    def debit_card?
      'DebitCard' == type
    end

    def card?
      ['DebitCard','CreditCard'].include?(type)
    end

    def cash?
      'Cash' == type
    end

    def check?
      'Check' == type
    end

    def credit_card_number
      new_record? ? @credit_card_number : credit_card_mask_number
    end

    def ach_account_number
      new_record? ? @ach_account_number : ach_account_number_mask
    end

  end
end
