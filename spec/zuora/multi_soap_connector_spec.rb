require 'spec_helper'

describe Zuora::MultiSoapConnector do
  subject { described_class.new(:model) }

  it { should be_a Zuora::SoapConnector }

  describe "defining multiple configs" do
    before :each do
      described_class.configure :one, :username => 'example', :password => 'test'
      described_class.configure :two, :username => 'example2', :password => 'test2'

    end

    it "stores each given config for use" do
      client = nil
      described_class.use_config :one do
        instance = described_class.new(:model)
        client = instance.current_client
      end
      client.config.username.should == 'example'
      client.config.password.should == 'test'

      described_class.use_config :two do
        instance = described_class.new(:model)
        client = instance.current_client
      end
      client.config.username.should == 'example2'
      client.config.password.should == 'test2'
    end

    it "only has a config within the :use_config block" do
      begin
        described_class.use_config :one do
          raise :foo
        end
      rescue
      end
      described_class.current_client.should be_nil
    end

    it "is thread safe when using configs" do
      mutex = Mutex.new
      cv = ConditionVariable.new
      run_order = []
      t1 = Thread.new do
        mutex.synchronize do
          described_class.use_config :one do
            run_order << 1
            cv.wait(mutex)
            run_order << 3
            instance = described_class.new(:model)
            client = instance.current_client
            client.config.username.should == 'example'
            client.config.password.should == 'test'
          end
        end
      end
      sleep 0.001
      t2 = Thread.new do
        mutex.synchronize do
          described_class.use_config :two do
            run_order << 2
            cv.signal
          end
        end
        Thread.stop
      end
      t1.join
      run_order.should == [1,2,3]
    end
  end
end
