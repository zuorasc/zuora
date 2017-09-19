module Namespace
  def zuora_namespace(uri)
    Zuora::Api.instance.client.operation(:query).build.send(:namespace_by_uri, uri)
  end

  def zns
    zuora_namespace('http://api.zuora.com/')
  end

  def ons
    zuora_namespace('http://object.api.zuora.com/')
  end
end
