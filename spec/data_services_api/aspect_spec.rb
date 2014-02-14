require './spec/minitest_helper'

require 'json'
require 'data_services_api/service'
require 'data_services_api/dataset'
require 'data_services_api/aspect'

describe "DataServiceApi::Aspect" do
  before do
    VCR.insert_cassette name, :record => :new_episodes
    @aspects = DataServicesApi::Service.new.dataset( "hpi" ).structure
    @aspect1 = @aspects[0]
  end

  after do
    VCR.eject_cassette
  end

  it "should have an id" do
    @aspect1.id.wont_be_nil
    @aspect1.id.wont_match( /^http:/ )
  end

  it "should have a URI" do
    @aspect1.uri.must_match /^http:/
  end

  it "should have a label" do
    @aspect1.label.must_match /^Smoothed/
  end

  it "should have a description" do
    @aspect1.description.must_match /^Smoothed/
  end

  it "should not be optional" do
    @aspect1.optional?.must_equal false
  end

  it "should not be multi-valued" do
    @aspect1.multi_valued?.must_equal false
  end

  it "should have a range type" do
    @aspect1.range_type.must_equal "http://www.w3.org/2001/XMLSchema#float"
  end

  it "should have a reference to the service object" do
    @aspect1.service.wont_be_nil
    @aspect1.service.url.wont_be_nil
  end
end
