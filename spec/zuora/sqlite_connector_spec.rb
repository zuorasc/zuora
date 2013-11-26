require 'spec_helper'
require 'zuora/sqlite_connector'

describe Zuora::SqliteConnector do
  describe :build_schema do
    before :each do
      @models = Zuora::Objects::Base.subclasses
      described_class.build_schema

      @db = described_class.db
    end

    it "builds a table schema for all Zuora::Object::Base classes" do
      result = @db.execute "SELECT t.sql sql FROM 'main'.sqlite_master t WHERE t.type='table'"
      sqlite_system_tables = 1
      result.length.should == @models.length + sqlite_system_tables
    end

    it "creates a column for each attribute" do
      @models.each do |m|
        table_name = described_class.table_name(m)
        table = @db.table_info(table_name)
        columns = table.map {|t| t["name"] }
        camel_attrs = m.attributes.map { |a| a.to_s.zuora_camelize }
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

    describe :where do
      before :each do
        @model = Zuora::Objects::Product
        @db = described_class.db

        @product1 = @model.new :name => 'Product One'
        @product1.create
        @product2 = @model.new :name => 'Another One'
        @product2.create
      end

      it "returns matching records" do
        records = @model.where(:name => 'Product One')
        records.first.name.should == @product1.name
        records.first.id.should == @product1.id
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

    describe "factories" do
      before :each do
        @product = Factory(:product)
      end

      it "should exists" do
        @product.should be
      end
    end
  end


end
