module Zuora::Objects
  # TODO: If you specify Specific Months, you must also set the SpecificBillingPeriod field.
  # TODO: You cannot create a Discount-Fixed Amount or Discount-Percentage type of ChargeModel.
  # TODO: support UOM validations for specific charge models (docs dont match examples)
  # TODO: do not allow changing charge_type for existing objects (via example usage for update docs)
  class ProductRatePlanCharge < Base
    belongs_to :product_rate_plan
    has_many :product_rate_plan_charge_tiers

    BILL_CYCLE_TYPES            = %w(DefaultFromCustomer SpecificDayofMonth SubscriptionStartDay ChargeTriggerDay)
    BILLING_PERIODS             = ['Month','Quarter','Annual','Semi-Annual','Specific Months']
    BILLING_PERIOD_ALIGNMENTS   = %w(AlignToCharge AlignToSubscriptionStart AlignToTermStart)
    CHARGE_MODELS               = ['Discount-Fixed Amount', 'Discount-Percentage', 'Flat Fee Pricing', 'Per Unit Pricing',
                                   'Overage Pricing', 'Tiered Pricing', 'Tiered with Overage Pricing', 'Volume Pricing']
    CHARGE_TYPES                = %w(OneTime Recurring Usage)
    INCLUDED_UNITS              = ['Tiered Pricing','Tiered with Overage Pricing','Volume Pricing']
    OVERAGE_CALCULATION_OPTIONS = %w(EndOfSmoothingPeriod PerBillingPeriod)
    OVERAGE_UNUSED_UNITS_CREDIT_OPTIONS = %w(NoCredit CreditBySpecificRate)
    REV_REC_TRIGGER_CONDITIONS =  %w(ContractEffectiveDate ServiceActivationDate CustomerAcceptanceDate)
    SMOOTHING_MODELS = %w(RollingWindow Rollover)

    validates_presence_of :product_rate_plan_id, :name, :product_rate_plan_charge_tiers
    validates_length_of :accounting_code, :maximum => 100, :allow_nil => true
    validates_numericality_of :bill_cycle_day, :only_integer => true, :less_than_or_equal_to => 31, :allow_nil => true
    validates_inclusion_of :bill_cycle_type, :in => BILL_CYCLE_TYPES
    validates_inclusion_of :billing_period, :in => BILLING_PERIODS
    validates_inclusion_of :billing_period_alignment, :in => BILLING_PERIOD_ALIGNMENTS
    validates_inclusion_of :charge_model, :in => CHARGE_MODELS
    validates_inclusion_of :charge_type, :in => CHARGE_TYPES
    validates_numericality_of :default_quantity, :if => Proc.new { |prpc| prpc.charge_model == 'Per Unit Pricing' }
    validates_length_of :description, :maximum => 500, :allow_nil => true
    validates_numericality_of :included_units, :unless => Proc.new { |prpc| INCLUDED_UNITS.include?(prpc.charge_model) }
    validates_numericality_of :max_quantity, :allow_nil => true
    validates_numericality_of :min_quantity, :allow_nil => true
    validates_length_of :name, :maximum => 100, :allow_nil => true
    validates_numericality_of :bill_cycle_day, :only_integer => true, :allow_nil => true
    validates_inclusion_of :overage_calculation_option, :in => OVERAGE_CALCULATION_OPTIONS, :allow_nil => true
    validates_inclusion_of :overage_unused_units_credit_option, :in => OVERAGE_UNUSED_UNITS_CREDIT_OPTIONS, :allow_nil => true
    validates_numericality_of :price_increase_percentage, :only_integer => true, :less_than_or_equal_to => 100, :greater_than_or_equal_to => -100, :allow_nil => true
    validates_inclusion_of :rev_rec_trigger_condition, :in => REV_REC_TRIGGER_CONDITIONS, :allow_nil => true
    validates_inclusion_of :smoothing_model, :in => SMOOTHING_MODELS
    validates_numericality_of :specific_billing_period, :only_integer => true, :if => Proc.new { |prpc| prpc.billing_period == 'Specific Months' }
    validates_inclusion_of :trigger_event, :in => %w(ContractEffective ServiceActivation CustomerAcceptance SpecificDate)
    validates_inclusion_of :use_discount_specific_accounting_code, :in => [true, false], :allow_nil => true

    define_attributes do
      read_only :created_by_id, :created_date, :updated_by_id, :update_date 
      complex :product_rate_plan_charge_tier_data => :product_rate_plan_charge_tiers
    end
  end
end
