Factory.define :product, :class => Zuora::Objects::Product do |f|
  f.sequence(:name){|n| "Example Product #{n}"}
  f.effective_start_date DateTime.now
  f.effective_end_date   DateTime.now + 10.days
end

Factory.define :product_catalog, :parent => :product do |f|
  f.after_create do |product|
    rate_plan = Factory.create(:product_rate_plan, :product => product)    
    Factory.create(:product_rate_plan_charge, :product_rate_plan => rate_plan)
  end 
end
