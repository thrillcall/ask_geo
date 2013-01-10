require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "AskGeo" do
  describe "#lookup" do
    before :each do
      @client = AskGeo.new(
        :account_id => ASKGEO_ACCOUNT_ID,
        :api_key    => ASKGEO_API_KEY
      )
    end

    it "should support points specified by comma-separated lat,lon string" do
      @client.lookup("47.62057,-122.349761")['TimeZoneId'].should == 'America/Los_Angeles'
    end

    it "should support points specified by {:lat,:lon} hash" do
      @client.lookup(:lat => 47.62057, :lon => -122.349761)['TimeZoneId'].should == 'America/Los_Angeles'
    end

    it "should get a single response for a single point" do
      response = @client.lookup("47.62057,-122.349761")
      response.should be_a Hash
      response['TimeZoneId'].should == 'America/Los_Angeles'
      (response['CurrentOffsetMs'] % 3600000).should == 0
      (-8..-7).should include(response['CurrentOffsetMs'] / 3600000)
    end

    it "should get multiple responses for multiple points" do
      needle = {
        :lat => 47.62057,
        :lon => -122.349761
      }

      empire = {
        :lat  => 40.748529,
        :lon  => -73.98563
      }

      response = @client.lookup([needle, empire])
      response.should be_an Array
      response.should have(2).responses

      needle_response = response.first
      needle_response['TimeZoneId'].should == 'America/Los_Angeles'
      (needle_response['CurrentOffsetMs'] % 3600000).should == 0
      (-8..-7).should include(needle_response['CurrentOffsetMs'] / 3600000)

      empire_response = response.last
      empire_response['TimeZoneId'].should == 'America/New_York'
      (empire_response['CurrentOffsetMs'] % 3600000).should == 0
      (-5..-4).should include(empire_response['CurrentOffsetMs'] / 3600000)
    end

    it "should raise AskGeo::APIError on malformed points" do
      expect{@client.lookup("47.62057")}.to raise_exception AskGeo::APIError
    end
  end
end
