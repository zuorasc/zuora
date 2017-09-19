module Zuora::Objects
  class Product < Base
    has_many :product_rate_plans

    validates_inclusion_of :category, :in => ['DefaultCatalog'], :allow_nil => true
    validates_length_of :description, :maximum => 500, :allow_nil => true

    # validates_date_of :effective_start_date, :effective_end_date
    validates_length_of :name, :maximum => 100, :allow_nil => true
    validates_length_of :sku, :maximum => 50, :allow_nil => true

    define_attributes do
      read_only :created_by_id, :created_date, :updated_by_id, :updated_date
    end
  end
end
