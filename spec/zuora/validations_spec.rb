require 'spec_helper'

describe "Validations" do

  class ExampleObject
    include ActiveModel::Validations
    include Zuora::Validations
    attr_accessor :validated_at, :birthday
    validates :birthday, :date => true
    validates :validated_at, :date_time => true
  end

  before do
    @obj = ExampleObject.new
  end

  describe "validating date" do
    it "allows date objects" do
      [Date.today].each do |val|
        @obj.birthday = val
        @obj.valid?
        @obj.errors[:birthday].should be_blank
      end
    end

    it "does not allow invalid types" do
      [1, 'foobar', '', /s/].each do |val|
        @obj.birthday = val
        @obj.valid?
        @obj.errors[:birthday].should include('is not a valid date')
      end
    end
  end

  describe "validating date_time" do
    it "allows date and time related objects" do
      [DateTime.now, Time.now].each do |val|
        @obj.validated_at = val
        @obj.valid?
        @obj.errors[:validated_at].should be_blank
      end
    end

    it "does not allow invalid types" do
      [1, 'foobar', '', /s/].each do |val|
        @obj.validated_at = val
        @obj.valid?
        @obj.errors[:validated_at].should include('is not a valid datetime')
      end
    end

  end
end
