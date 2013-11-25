require 'spec_helper'

describe String do
  it "provides a zuora compatible camelize method" do
    "sso_id__c".zuora_camelize.should eq "SsoId__c"
    "SsoId__c".underscore.zuora_camelize.should eq "SsoId__c"
    "some__c_other_thing_c".zuora_camelize.should eq "Some_cOtherThingC"
  end
end