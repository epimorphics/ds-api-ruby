require './spec/minitest_helper'

require 'json'
require 'data_services_api/service'
require 'data_services_api/dataset'
require 'data_services_api/aspect'
require 'data_services_api/query_generator'
require 'pry'

describe "DataServiceApi::QueryGenerator" do
  before do
    VCR.insert_cassette name, :record => :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  it "should start with an empty query" do
    pattern = {}
    query = DataServicesApi::QueryGenerator.new
    query.to_json.wont_be_nil
    query.to_json.must_match_json_expression pattern
  end

  it "should allow adding an equality clause" do
    pattern = {foo: {"@eq" => "bar"}}

    query = DataServicesApi::QueryGenerator.new
              .eq( "foo", "bar" )

    query.to_json.wont_be_nil
    query.to_json.must_match_json_expression pattern
  end

  it "should allow adding a relational operator clause" do
    query = DataServicesApi::QueryGenerator.new

    query.ge( "foo", 1 ).to_json.must_match_json_expression( {foo: {"@ge" => 1}} )
    query.gt( "foo", 1 ).to_json.must_match_json_expression( {foo: {"@gt" => 1}} )
    query.le( "foo", 1 ).to_json.must_match_json_expression( {foo: {"@le" => 1}} )
    query.lt( "foo", 1 ).to_json.must_match_json_expression( {foo: {"@lt" => 1}} )
  end

  it "should allow sorting to specified" do
    query = DataServicesApi::QueryGenerator.new
    query.sort( :up, "foo" ).to_json.must_match_json_expression( {"@sort" => [{"@up" => "foo"}]} )
    query.sort( :up, "foo" ).sort( :down, "bar" ).to_json.must_match_json_expression( {"@sort" => [{"@up" => "foo"}, {"@down" => "bar"}]} )
  end

  it "should allow a range to be specified" do
    query = DataServicesApi::QueryGenerator.new

    query.le( "foo", 10 )
         .ge( "foo", 1 )
         .to_json
         .must_match_json_expression( {foo: {"@ge" => 1,"@le" => 10}} )
  end

  it "should allow a text search option to be added" do
    query = DataServicesApi::QueryGenerator.new
    query.search( "foo" )
         .to_json
         .must_match_json_expression( {"@search" => "foo"} )
  end

  it "should allow a text search against a specific property to be added" do
    query = DataServicesApi::QueryGenerator.new
    query.search_property( "foo:bar", "foo" )
         .to_json
         .must_match_json_expression( {"@search" => {"@value" => "foo", "@property" => "foo:bar"}} )
  end

  it "should allow a text search against a specific aspect to be added" do
    query = DataServicesApi::QueryGenerator.new
    query.search_aspect( "foo:aspect", "foo" )
         .to_json
         .must_match_json_expression( {"foo:aspect" => {"@search" => "foo"}} )
  end

  it "should allow a text search against a specific property of an aspect to be added" do
    query = DataServicesApi::QueryGenerator.new
    query.search_aspect_property( "foo:aspect", "foo:bar", "foo" )
         .to_json
         .must_match_json_expression( {"foo:aspect" => {"@search" => {"@value" => "foo", "@property" => "foo:bar"}}} )
  end

end
