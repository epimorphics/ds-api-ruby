require './spec/minitest_helper'

require 'json'
require 'data_services_api/service'
require 'data_services_api/dataset'
require 'data_services_api/aspect'
require 'data_services_api/query_generator'

describe "DataServiceApi::QueryGenerator" do
  before do
    VCR.insert_cassette name, :record => :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  it "start with an empty query" do
    pattern = {}
    query = DataServicesApi::QueryGenerator.new
    query.to_json.wont_be_nil
    query.to_json.must_match_json_expression pattern
  end

end
