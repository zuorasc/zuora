module Zuora::Objects
  class Invoice < Base
    belongs_to :account

    has_many :invoice_items
    has_many :invoice_adjustments
    has_many :invoice_item_adjustments

    validates_presence_of(
      :account_id, :amount, :balance, :due_date, :invoice_date, :invoice_number,
      :status, :target_date
    )

    validates_numericality_of :adjustment_amount, :allow_nil => true
    validates_numericality_of :amount
    validates_numericality_of :balance, :allow_nil => true
    validates_length_of       :comments, :maximum => 255
    validates_datetime_of     :due_date
    validates_datetime_of     :invoice_date
    validates_inclusion_of    :includes_one_time, :in => [true, false]
    validates_inclusion_of    :includes_recurring, :in => [true, false]
    validates_inclusion_of    :includes_usage, :in => [true, false]
    validates_length_of       :invoice_number, :maximum => 255  # String
    validates_datetime_of     :last_email_sent_date, :allow_nil => true
    validates_numericality_of :payment_amount, :allow_nil => true
    validates_datetime_of     :posted_date, :allow_nil => true
    validates_numericality_of :refund_amount, :allow_nil => true
    validates_inclusion_of    :status, :in => %w(Canceled Draft Error Posted), :allow_nil => true
    validates_datetime_of     :target_date
    validates_inclusion_of    :transferred_to_accounting, :in => %w(Processing Yes Error Ignore), :allow_nil => true
    validates_datetime_of     :updated_date

    define_attributes do
      read_only(
        :created_by_id,
        :created_date,
        :invoice_number,
        :last_email_sent_date,
        :payment_amount,
        :posted_by,
        :posted_date,
        :refund_amount,
        :target_date,
        :tax_amount,
        :tax_exempt_amount,
        :updated_by,
        :updated_by_id,
        :updated_date
      )
      defaults(
        :includes_one_time => true,
        :includes_recurring => true,
        :includes_usage => true,
        :invoice_date => Proc.new { Date.today }
      )

      defer :body
    end
  end
end
