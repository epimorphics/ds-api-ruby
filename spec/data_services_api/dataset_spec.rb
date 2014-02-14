require './spec/minitest_helper'

require 'json'
require 'data_services_api/service'
require 'data_services_api/dataset'
require 'data_services_api/aspect'

describe "DataServiceApi::Dataset" do
  before do
    VCR.insert_cassette name, :record => :new_episodes
    @dataset = DataServicesApi::Service.new.dataset( "hpi" )
  end

  after do
    VCR.eject_cassette
  end

  it "should have an id" do
    @dataset.id.wont_be_nil
  end

  it "should have a label" do
    @dataset.label.must_match /House price index/
  end

  it "should have a description" do
    @dataset.description.must_match /A Data Cube of house price/
  end

  it "should describe its own structure as a set of aspects" do
    # VCR.use_cassette( name, :record => :new_episodes) do
      structure = @dataset.structure
      structure.wont_be_nil
      structure.must_respond_to :size

      structure.each do |aspect|
        aspect.id.wont_be_nil
      end
    # end
  end

  it "should have a reference to the service object" do
    @dataset.service.wont_be_nil
    @dataset.service.url.wont_be_nil
  end
end
