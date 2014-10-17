class MockResponse
  class << self
    def responds_with(fixture, status=200)
      Zuora::Api.instance.stub(:authenticated?, true) do
        responder = proc do |env|
          [status, { "Content-Type" => 'text/xml'}, Fixture.response(fixture)]
        end

        Artifice.activate_with(responder) do
          yield
        end
      end
    end
  end
end
