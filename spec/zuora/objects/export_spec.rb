require 'spec_helper'

describe Zuora::Objects::Export do

  describe "read only attributes" do
    it "should be defined" do
      subject.read_only_attributes.should == [:created_by_id,
        :created_date, :updated_by_id, :updated_date]
    end
  end

  describe "attributes=" do
    it "should assign attributes to an existing instance from passed in hash" do
      export = Zuora::Objects::Export.new(:name => "Test Name")
      export.attributes = {:name => "New Name"}
      export.name.should == "New Name"
    end

    it "should assign attributes to an existing instance by setting the attiribute" do
    	export = Zuora::Objects::Export.new
    	export.name = "Test Name"
    	export.name.should == "Test Name"
    end
  end
end
