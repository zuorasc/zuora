# Zuora [![Build Status](https://secure.travis-ci.org/wildfireapp/zuora.png?branch=master)](http://travis-ci.org/wildfireapp/zuora) [![Gemnasium](https://gemnasium.com/wildfireapp/zuora.png)](https://gemnasium.com/wildfireapp/zuora)

This library allows you to interact with [Zuora](http://www.zuora.com) billing platform directly using 
familiar [ActiveModel](https://github.com/rails/rails/tree/master/activemodel) based objects.

## Requirements
  * [bundler](https://github.com/carlhuda/bundler)
  * [active_support](https://github.com/rails/rails/tree/master/activesupport)
  * [savon](https://github.com/rubiii/savon)
  * [wasabi](https://github.com/rubiii/wasabi)

All additional requirements for development should be referenced in the provided zuora.gemspec and Gemfile.

## Installation

    git clone git@github.com:wildfireapp/zuora.git

## Getting Started

    $ bundle install
    $ bundle exec irb -rzuora

```
  Zuora.configure(:username => 'USER', :password => 'PASS', sandbox: true, logger: true)
    
  account = Zuora::Objects::Account.new
   => #<Zuora::Objects::Account:0x00000002cd25b0 @changed_attributes={"auto_pay"=>nil, "currency"=>nil, 
  "batch"=>nil, "bill_cycle_day"=>nil, "status"=>nil, "payment_term"=>nil}, @auto_pay=false, @currency="USD",
  @batch="Batch1", @bill_cycle_day=1, @status="Draft", @payment_term="Due Upon Receipt">
  
  account.name = "Test"
   => "Test"
   
  account.create
   => true
  
  created_account = Zuora::Objects::Account.find(account.id)
   => #<Zuora::Objects::Account:0x00000003caafc8 @changed_attributes={}, @auto_pay=false, @currency="USD", 
  @batch="Batch1", @bill_cycle_day=1, @status="Draft", @payment_term="Due Upon Receipt", 
  @id="2c92c0f83c1de760013c449bc26e555b", @account_number="A00000008", @allow_invoice_edit=false, 
  @balance=#<BigDecimal:3c895f8,'0.0',9(18)>, @bcd_setting_option="ManualSet", 
  @created_by_id="2c92c0f83b02a9dc013b0a7e26a03d00", @created_date=Wed, 16 Jan 2013 10:25:24 -0800, 
  @invoice_delivery_prefs_email=false, @invoice_delivery_prefs_print=false, @name="Test", 
  @updated_by_id="2c92c0f83b02a9dc013b0a7e26a03d00", @updated_date=Wed, 16 Jan 2013 10:25:24 -0800>
```

## Documentation
  You can generate up to date documentation with the provided rake task.

    $ rake doc
    $ open doc/index.html

## Advanced Usage
  Review the generated documentation for usage patterns and examples of using specific zObjects.

## Test Suite
  This library comes with a full test suite, which can be ran using the standard rake utility.

      $ rake spec

## Live Integration Suite
  There is also a live suite which you can test against your sandbox account.
  This can by ran by setting up your credentials and running the integration suite.

  **Do not run this suite using your production credentials. Doing so may destroy
  data although every precaution has been made to avoid any destructive behavior.**

      $ ZUORA_USER=login ZUORA_PASS=password rake spec:integrations

## Support & Maintenance
  This library currently supports Zuora's SOAP API version 38.

  If you would like to test out the **EXPERIMENTAL** API version 51 support, see
  the a51 branch and please file bugs and pull requests against it.

## Contributors
  * Josh Martin <joshuamartin@google.com>
  * Alex Reyes <alexreyes@google.com>
  * Wael Nasreddine <wnasreddine@google.com>
  * [mdemin914](http://github.com/mdemin914)
  * [jmonline](http://github.com/jmonline)

## Credits
  * [Wildfire Ineractive](http://www.wildfireapp.com) for facilitating the development and maintenance of the project.
  * [Zuora](http://www.zuora.com) for providing us with the opportunity to share this library with the community.

