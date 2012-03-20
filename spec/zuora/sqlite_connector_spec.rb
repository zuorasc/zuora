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
        columns = table.map {|t| t["name"].to_sym }
        (m.attributes - columns).should == []
      end
    end
  end

  describe :create do
    before :each do
      described_class.build_schema
      @model = Zuora::Objects::Product.new
      @model.name = 'A Product'
      @instance = described_class.new @model
      @db = described_class.db
    end

    it "creates a record in the table" do
      @instance.create
      table_name = described_class.table_name(@model.class)
      result = @db.execute "SELECT * FROM #{table_name}"
      result.length.should == 1
    end

    it "returns success and new id in ash" do
      result = @instance.create[:create_response]
      result[:success].should be_true
      result[:id].should_not be_nil
    end
  end
end
