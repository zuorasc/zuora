require 'spec_helper'
require 'date'

describe Zuora::Objects::AmendRequest do
  describe "most persistence methods" do
    it "are not publicly available" do
      [:destroy, :where, :find, :create].each do |meth|
        subject.public_methods.should_not include(meth)
      end
    end
  end

  describe "validations" do
    describe "#must_have_usable" do
      context "on account" do
        before do
          # Minimum fields required for a valid, saved Amendment
          @amendment = Zuora::Objects::Amendment.new(
            id: '2c3yiy4u6hu6twguei5thewt',
            subscription_id: '394uagh83y48y94hgutg7idftrguit4',
            name: 'Example Amendment',
            status: 'Completed',
            type: 'Renewal',
            contract_effective_date: DateTime.now
          )
          @request = Zuora::Objects::AmendRequest.new(amendment: @amendment)
        end

        it "should contain errors when the amendment is not valid" do
          @amendment.should_receive(:valid?).and_return(false)
          @request.must_have_usable(:amendment)
          @request.errors[:amendment].should include("is invalid")
        end

        it "should not add errors when the amendment is valid" do
          @amendment.should_receive(:valid?).and_return(true)
          @request.must_have_usable(:amendment)
          @request.errors[:amendment].should be_blank
        end
      end
    end
  end

  describe "requests" do
    before do
    end
  end
end
