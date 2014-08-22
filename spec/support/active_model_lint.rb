shared_examples_for "ActiveModel" do
  require 'active_model/lint'
  require 'minitest/autorun'
  require 'minitest/assertions'
  include ActiveModel::Lint::Tests
  # include Minitest::Assertions

  ActiveModel::Lint::Tests.public_instance_methods.map { |method| method.to_s }.grep(/^test/).each do |method|
    # require 'pry'; binding.pry
    puts "responds to assert? #{respond_to? :assert}"
    example(method.gsub('_', ' ')){ send method }
  end

  def model
    subject
  end

  def assert(thing_to_be_asserted, message = nil)
    thing_to_be_asserted.should be_true
  end
end
