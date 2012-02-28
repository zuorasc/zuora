module Zuora::Objects
  class RatePlan < Base
    belongs_to :amendment_subscription_rate_plan, :class => 'RatePlan'
    belongs_to :product_rate_plan
    has_many :rate_plan_charges
    belongs_to :subscription

    validates_presence_of :name, :product_rate_plan_id, :subscription_id

    validates_inclusion_of :amendment_type, :in => %w(Cancellation NewProduct OwnerTransfer RemoveProduct Renewal TermsAndConditions UpdateProduct), :allow_nil => true
    validates_length_of :created_by_id, :maximum => 32, :allow_nil => true
    validates_length_of :name, :maximum => 50, :allow_nil => true
    validates_length_of :updated_by_id, :maximum => 32, :allow_nil => true

    define_attributes do
      read_only :created_by_id, :created_date, :updated_by_id, :updated_date
    end
  end
end
