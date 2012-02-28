class Fixture
  class << self
    def response(fixture)
      path = File.expand_path "../../fixtures/responses/#{fixture}.xml", __FILE__
      raise ArgumentError, "Unable to load: #{path}" unless File.exist? path
      File.read path
    end
  end
end
