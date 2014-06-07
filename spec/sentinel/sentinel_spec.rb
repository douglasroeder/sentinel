require 'spec_helper'

RSpec.describe Sentinel do
  before :each do
    Sentinel.oauth_token = "OAUTH_TOKEN"
    Sentinel.instance_url = "INSTANCE_URL"
  end

  it { expect(Sentinel.oauth_token).to eql("OAUTH_TOKEN") }
  it { expect(Sentinel.instance_url).to eql("INSTANCE_URL") }
  it { expect(Sentinel.valid_environment?).to eql(true) }

  context "configuring library" do

    it 'should be invalid if missing configuration attribute' do
      allow(Sentinel).to receive(:oauth_token) { "" }

      expect(Sentinel.valid_environment?).to eql(false)
    end

    it "yields Sentinel" do
      expect {|block|
        Sentinel.configure(&block)
      }.to yield_with_args(Sentinel)
    end
  end

  context "client instance" do
    it "should raise exception on invalid environments" do
      allow(Sentinel).to receive(:oauth_token) { "" }

      expect {
        Sentinel.client
      }.to raise_exception(Sentinel::InvalidEnvironmentError)
    end

    it "should call restforce" do
      expect(Restforce).to receive(:new)

      Sentinel.client
    end
  end
end
