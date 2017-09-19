require 'spec_helper'

describe Zuora::Objects::Amendment do
  #date validation has changed
  # it "validates datetime of several attributes" do
  #   subject.status = 'PendingAcceptance' # required for service_activation_date
  #   [:contract_effective_date, :customer_acceptance_date, :effective_date, :service_activation_date].each do |attr|
  #     subject.send("#{attr}=", 'invalid')
  #     subject.should_not be_valid
  #     subject.errors[attr].should include('is not a valid datetime')
  #   end
  # end
  #
  # it "validates date of term_start_date" do
  #   subject.type = 'TermsAndConditions'
  #   subject.term_start_date = 'invalid'
  #   subject.should_not be_valid
  #   subject.errors[:term_start_date].should include('is not a valid date')
  # end
end
