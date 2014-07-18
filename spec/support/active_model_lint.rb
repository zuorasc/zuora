shared_examples_for "ActiveModel" do
  require 'active_model/lint'
  require 'minitest/autorun'
  include ActiveModel::Lint::Tests
  include MiniTest::Assertions

  ActiveModel::Lint::Tests.public_instance_methods.map { |method| method.to_s }.grep(/^test/).each do |method|
    example(method.gsub('_', ' ')){ send method }
  end

  def model
    subject
  end
end
