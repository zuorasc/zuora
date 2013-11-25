require 'spec_helper'

describe String do
  # Custom fields append "__c" at the end of the filed name
  # ref: http://knowledgecenter.zuora.com/D_Zuora_APIs/SOAP_API/C_SOAP_API_Reference/A_SOAP_Basics/D_Custom_Fields
  it "ignores camelization of trailing __c" do
    "sso_id__c".zuora_camelize.should eq "SsoId__c"
    "SsoId__c".underscore.zuora_camelize.should eq "SsoId__c"
  end

  it "camelizes instring __c" do
    "some__c_other_thing_c".zuora_camelize.should eq "SomeCOtherThingC"
  end
end
