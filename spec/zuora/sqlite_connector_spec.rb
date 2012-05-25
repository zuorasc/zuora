require 'spec_helper'
require 'zuora/sqlite_connector'

describe Zuora::SqliteConnector do
  describe :build_schema do
    before :each do
      mod = Zuora::Objects
      @models = mod.constants.select { |x| mod.const_defined?(x) && mod.const_get(x) < mod::Base }.map { |x| mod.const_get(x) }
      described_class.build_schema

      @db = described_class.db
    end

    it "builds a table schema for all Zuora::Object::Base classes" do
      result = @db.execute "SELECT t.sql sql FROM 'main'.sqlite_master t WHERE t.type='table'"
      result.length.should == @models.length
    end

    it "creates a column for each attribute" do
      @models.each do |m|
        table_name = described_class.table_name(m)
        table = @db.table_info(table_name)
        columns = table.map {|t| t["name"] }
        camel_attrs = m.attributes.map { |a| a.to_s.camelize }
        (camel_attrs - columns).should == []
      end
    end
  end


  describe "Behaviors for models using connector" do
    around :each do |example|
      old_class = Zuora::Objects::Base.connector_class
      Zuora::Objects::Base.connector_class = described_class
      described_class.build_schema
      example.run
      Zuora::Objects::Base.connector_class = old_class
    end

    describe "Arel like methods" do
      before :each do
        @model = Zuora::Objects::Product
        @db = described_class.db

        @product1 = @model.new :name => 'Product One'
        @product1.create
        @product2 = @model.new :name => 'Another One'
        @product2.create
      end

      describe :where do
        it "returns matching records" do
          records = @model.where(:name => 'Product One')
          records.first.name.should == @product1.name
          records.first.id.should == @product1.id
        end
      end

      describe :select do
        it "returns only selected fields" do
          records = @model.select([:id, :name]).where(:name => 'Product One')
          records.first.name.should == @product1.name
          records.first.id.should == @product1.id
          records.first.description.should == nil
        end
      end
    end


    describe :create do
      before :each do
        @model = Zuora::Objects::Product.new
        @model.name = 'A Product'
        @db = described_class.db
      end

      it "creates a record in the table" do
        @model.create
        table_name = described_class.table_name(@model.class)
        result = @db.execute "SELECT * FROM #{table_name}"
        result.length.should == 1
      end

      it "successfully updates the model id" do
        @model.create
        @model.id.should_not be_nil
      end
    end

    describe :update do
      before :each do
        described_class.build_schema
        @model = Zuora::Objects::Product.new
        @model.name = 'A Product'
        @model.create
        @db = described_class.db
        @model.name = 'New Product'
        @model.update
      end

      it "updates a record in the table" do
        table_name  = described_class.table_name(@model.class)
        result      = @db.execute "SELECT * FROM #{table_name} ORDER BY 'id' DESC"
        result.first.include?("New Product").should be
      end

      it "marks the model as unchanged" do
        @model.should_not be_changed
      end
    end

    describe :destroy do
      before :each do
        described_class.build_schema
        @model = Zuora::Objects::Product.new
        @model.name = 'A Product'
        @model.create
        @db = described_class.db
        @model.destroy
      end

      it "updates a record in the table" do
        table_name  = described_class.table_name(@model.class)
        result      = @db.execute "SELECT * FROM #{table_name} WHERE id=?", @model.id
        result.length.should == 0
      end

      it "marks the model as unchanged" do
        @model.should_not be_changed
      end
    end

    describe :subscribe do
      before :each do
        described_class.build_schema
        @acc = Zuora::Objects::Account.new
        @subscription = Zuora::Objects::Subscription.new
        @bill_to_contact = Zuora::Objects::Contact.new
        @payment_method = Zuora::Objects::PaymentMethod.new
        @sold_to_contact = Zuora::Objects::Contact.new
        @product_rate_plan = Zuora::Objects::ProductRatePlan.new

        @model = Zuora::Objects::SubscribeRequest.new
        @model.account = @acc
        @model.subscription = @subscription
        @model.bill_to_contact = @bill_to_contact
        @model.payment_method = @payment_method
        @model.sold_to_contact = @sold_to_contact
        @model.product_rate_plan = @product_rate_plan
      end

      it "calls create on all of the related objects" do
        @acc.should_receive(:create)
        @subscription.should_receive(:create)
        @bill_to_contact.should_receive(:create)
        @payment_method.should_receive(:create)
        @sold_to_contact.should_receive(:create)
        @product_rate_plan.should_receive(:create)

        @model.stub(:valid?).and_return(true)
        @model.create
      end

    end
  end

end
