require 'spec_helper'
require 'uri'

describe EY::Config do
  describe "environments" do
    it "get loaded from the config file" do
      write_yaml("environments" => {"production" => {"default" => true}})
      EY::Config.new.environments["production"]["default"].should be_true
    end

    it "are present when the config file has no environments key" do
      write_yaml({})
      EY::Config.new.environments.should == {}
    end
  end

  describe "endpoint" do
    it "defaults to production EY Cloud" do
      EY::Config.new.endpoint.should == EY::Config.new.default_endpoint
    end

    it "loads the endpoint from $CLOUD_URL" do
      ENV['CLOUD_URL'] = "http://fake.local/"
      EY::Config.new.endpoint.should == URI.parse('http://fake.local')
      ENV.delete('CLOUD_URL')
    end

    it "raises on an invalid endpoint" do
      ENV['CLOUD_URL'] = "non/absolute"
      lambda { EY::Config.new.endpoint }.
        should raise_error(EY::Config::ConfigurationError)
      ENV.delete('CLOUD_URL')
    end
  end

  describe "files" do
    before do
      FakeFS::FileSystem.add('config')
    end

    it "looks for config/ey.yml" do
      write_yaml({"environments" => {"staging"    => {"default" => true}}}, "ey.yml")
      write_yaml({"environments" => {"production" => {"default" => true}}}, "config/ey.yml")
      EY::Config.new.default_environment.should == "production"
    end

    it "looks for ey.yml" do
      write_yaml({"environments" => {"staging" => {"default" => true}}}, "ey.yml")
      EY::Config.new.default_environment.should == "staging"
    end
  end

end
