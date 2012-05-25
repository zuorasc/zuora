require 'spec_helper'

describe "Product Catalog" do
  before do
    authenticate!
    @product_name = generate_key
  end

  after do
    Zuora::Objects::Product.where(:name => @product_name).map(&:destroy)
  end
  
  it "creates a product catalog" do
    product_catalog = FactoryGirl.create(:product_catalog, :name => @product_name)
  end
end
