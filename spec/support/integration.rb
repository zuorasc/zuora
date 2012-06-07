def authenticate!
  Zuora.configure(:username => ENV['ZUORA_USER'], :password => ENV['ZUORA_PASS'], :sandbox => true)
  Zuora::Api.instance.authenticate!
  Zuora::Api.instance.should be_authenticated
rescue Zuora::Fault => e
  fail "Unable to authenticate. Please see the documentation regarding live testing configuration."
end

