require 'spec_helper'

describe Zuora::Objects::Contact do
  it "should have nil values for blank attributes" do
    MockResponse.responds_with(:contact_find_success) do
      contact = Zuora::Objects::Contact.find('4028e4873491cc770134972e75746e4c')
      contact.work_email.should be_nil
    end
  end

  it "should support dirty associations on belongs_to" do
    contact = Zuora::Objects::Contact.new
    contact.should_not be_changed
    contact.account = mock(Zuora::Objects::Account, :id => 42)
    contact.changes.should == {'account_id' => [nil, 42]}
  end

  describe "validations" do
    before :each do
      subject.should_not be_valid
    end

    it "requires first_name" do
      subject.errors[:first_name].should include("can't be blank")
    end

    it "requires last_name" do
      subject.errors[:last_name].should include("can't be blank")
    end
  end

  describe "read only attributes" do
    it "should be defined" do
      subject.read_only_attributes.should == [:created_by_id,
        :created_date, :updated_by_id, :updated_date]
    end
  end
end
