module Zuora::Objects
  # TODO: If you specify Specific Months, you must also set the SpecificBillingPeriod field.
  # TODO: You cannot create a Discount-Fixed Amount or Discount-Percentage type of ChargeModel.
  # TODO: support UOM validations for specific charge models (docs dont match examples)
  # TODO: do not allow changing charge_type for existing objects (via example usage for update docs)
  class RatePlanCharge < Base
    belongs_to :original, :class_name => 'RatePlanCharge'
    belongs_to :product_rate_plan_charge
    belongs_to :rate_plan
    
    has_many :rate_plan_charge_tiers

    CHARGE_MODELS = [ 
      "Flat Fee Pricing",
      "Per Unit Pricing",
      "Overage Pricing",
      "Tiered Pricing",
      "Tiered With Overage Pricing",
      "Volume Pricing",
      "Discount-Fixed Amount",
      "Discount-Percentage"
    ]


    validates_presence_of :product_rate_plan_charge_id, :rate_plan_id, :segment, :trigger_event

    validates_length_of :accounting_code, :maximum => 50, :allow_nil => true
    validates_inclusion_of :apply_discount_to, :allow_nil => true, :in => %w(
      NULL ONETIME RECURRING USAGE ONETIMERECURRING ONETIMEUSAGE RECURRINGUSAGE ONETIMERECURRINGUSAGE
    )
    validates_numericality_of :bill_cycle_day, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 31, :allow_nil => true
    validates_inclusion_of    :bill_cycle_type, :allow_nil => true, :in => %w(DefaultFromCustomer SpecificDayofMonth SubscriptionStartDay ChargeTriggerDay)
    validates_inclusion_of    :billing_period_alignment, :allow_nil => true, :in => %w(AlignToCharge AlignToSubscriptionStart AlignToTermStart)
    validates_datetime_of     :charged_through_date, :allow_nil => true
    validates_inclusion_of    :charge_model, :allow_nil => true, :in => CHARGE_MODELS
    validates_length_of       :charge_number, :maximum => 50  # String
    validates_inclusion_of    :charge_type, :in => %w(OneTime Recurring Usage)
    validates_length_of       :description, :maximum => 500
    validates_numericality_of :discount_amount, :allow_nil => true, :greater_than => 0
    validates_inclusion_of    :discount_level, :allow_nil => true, :in => %w(account rateplan subscription)
    validates_numericality_of :discount_percentage, :allow_nil => true, :greater_than => 0
    validates_numericality_of :dmrc, :allow_nil => true
    validates_numericality_of :dtcv, :allow_nil => true
    validates_datetime_of     :effective_end_date
    validates_datetime_of     :effective_start_date
    validates_numericality_of :included_units, :greater_than => 0, :if => Proc.new { |rpc| ['Overage','Tiered with Overage Pricing'].include?(rpc.charge_model) }
    validates_inclusion_of    :is_last_segment, :in => [true, false], :allow_nil => true
    validates_numericality_of :mrr, :allow_nil => true
    validates_length_of       :name, :maximum => 50
    validates_numericality_of :number_of_periods, :only_integer => true, :greater_than => 0, :allow_nil => true, :if => Proc.new { |rpc| ['Overage','Tiered with Overage Pricing'].include?(rpc.charge_model) }
    validates_length_of       :original_id, :maximum => 50  # String
    validates_inclusion_of    :overage_calculation_option, :in => %w(EndOfSmoothingPeriod PerBillingPeriod), :allow_nil => true
    validates_numericality_of :overage_price, :greater_than_or_equal_to => 0, :allow_nil => true
    validates_inclusion_of    :overage_unused_units_credit_option, :allow_nil => true, :in => %w(NoCredit CreditBySpecificRate), :if => Proc.new { |rpc| ['Overage','Tiered with Overage Pricing'].include?(rpc.charge_model) }
    validates_numericality_of :price, :allow_nil => true
    validates_numericality_of :price_increase_percentage, :less_than_or_equal_to => 100, :greater_than_or_equal_to => -100, :allow_nil => true
    validates_datetime_of     :processed_through_date, :allow_nil => true
    validates_numericality_of :quantity, :allow_nil => true, :greater_than_or_equal_to => 0
    validates_numericality_of :rollover_balance, :allow_nil => true
    validates_numericality_of :segment, :integer_only => true, :greater_than_or_equal_to => 1
    validates_numericality_of :tcv
    validates_datetime_of     :trigger_date, :allow_nil => true
    validates_inclusion_of    :trigger_event, :in => %w(ContractEffective CustomerAcceptance ServiceActivation SpecificDate)
    validates_numericality_of :unused_units_credit_rates, :if => Proc.new { |rpc| ['Overage','Tiered with Overage Pricing'].include?(rpc.charge_model) }
    validates_numericality_of :up_to_periods, :integer_only => true, :allow_nil => true
    validates_inclusion_of    :use_discount_specific_accounting_code, :in => [true, false], :allow_nil => true
    validates_numericality_of :version, :integer_only => true, :greater_than_or_equal_to => 1

    # NOTE: rollover_balance cannot be queried in the standard way, it is disabled currently
    #       by including it in both read/write only attributes
    define_attributes do
      read_only(
        :charged_through_date, :created_by_id, :created_date, :dmrc, :dtcv,
        :effective_end_date, :effective_start_date, :mrr, :processed_through_date,
        :rollover_balance, :tcv, :updated_by_id, :update_date, :version
      )

      defer :rollover_balance, :overage_price, :price, :included_units, :discount_amount, :discount_percentage

      defaults(
        :overage_calculation_option => 'EndOfSmoothingPeriod',
        :overage_unused_units_credit_option => 'NoCredit'
      )
    end
  end
end
