require 'spec_helper'

describe Zuora::Objects::Invoice do

  it "validates datetime of several attributes" do
    [:due_date, :invoice_date, :target_date,].each do |attr|
      subject.errors.clear
      subject.send("#{attr}=", 'invalid')
      subject.should_not be_valid
      subject.errors[attr].should include('is not a valid date')
    end
    [:due_date, :invoice_date, :last_email_sent_date, :posted_date, :target_date, :updated_date,].each do |attr|
      subject.errors.clear
      value = DateTime.parse('2011-12-28T17:23:27.000-08:00')
      subject.send("#{attr}=", value)
      subject.errors[attr].should_not include('is not a valid datetime'), "attribute: #{attr}\tvalue: #{value.class} #{value}"
    end
  end

end
