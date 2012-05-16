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

    Zuora.configure(:username => 'USER', :password => 'PASS')

    account = Zuora::Objects::Account.create(:account_number => '12345')
    # => <Zuora::Objects::Account :account_number => 12345, :id => 'abc123'>
    Zuora::Objects::Account.find('abc123')
    # => <Zuora::Objects::Account :account_number => 12345, :id => 'abc123'>
    account.destroy
    # => true

## Documentation
  You can generate up to date documentation with the provided a rake task.

    $ rake doc
    $ open doc/index.html

## Advanced Usage
  Review the generated documentation for usage patterns and examples of using specific zObjects.

## Test Suite
  This library comes with a full test suite, which can be run using the stanard rake utility.

      $ rake spec

## Multiple Connectors
  There are mutiple connectors available to us to communicate from library to Zuora (or even a test
  SQLite database)

  To set your connector:

    Zuora::Objects::Base.connector_class = Zuora::YourChosenConnector

### Default SOAPConnector
  This one is for normal usage, and is configured in the usual way. You do not need to explicitly
  set this connector.  It uses the SOAP api for Zuora

### SQLite Connector
  This connector is for usage in tests, and allows you to model fixtures and factories using the
  ZObjects, but within an in memory SQLite database.  To use this:

    require 'zuora/sqlite_connector'
    Zuora::Objects::Base.connector_class = Zuora::SqliteConnector
    Zuora::SqliteConnector.build_schema #Builds the sqlite schema from the ZObjects defined

### Multiple Config SOAPConnector
  This connector is for when you need to authenticate with Zuora using mutiple credentials, and
  allows you to specify within a block which config to use.  This is done per-thread, so will
  not effect other requests.

    Zuora::Objects::Base.connector_class = Zuora::MultiSoapConnector

    # Note we don't use Zuora.configure, as that's global:
    Zuora::MultiSoapConnector.configure :named_config, :username => 'u', :password => 'p'
    Zuora::MultiSoapConnector.configure :another_config, :username => 'u2', :password => 'p2'

    #To select a specific one at run time (required)
    Zuora::MultiSoapConnector.use_config :named_config do
      # Make use of ZObjects where, will authenticate and use
      # specific config
      Accounts.where('condition = TRUE')
    end

## Live Integration Suite
  There is also a live suite which you can test against your sandbox account.
  This can by ran by setting up your credentials and running the integration suite.

  **Do not run this suite using your production credentials. Doing so may destroy
  data although every precaution has been made to avoid any destructive behavior.**

      $ ZUORA_USER=login ZUORA_PASS=password rake spec:integrations

## Support & Maintenance
  This library currently supports Zuora's SOAP API version 38.

## Contributors
  * Josh Martin <josh.martin@wildfireapp.com>
  * Alex Reyes <alex.reyes@wildfireapp.com>
  * Wael Nasreddine <wael.nasreddine@wildfireapp.com>

## Credits
  * [Wildfire Ineractive](http://www.wildfireapp.com) for facilitating the development and maintenance of the project.
  * [Zuora](http://www.zuora.com) for providing us with the opportunity to share this library with the community.

