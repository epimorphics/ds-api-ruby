# frozen_string_literal: true

require './spec/minitest_helper'

describe 'DataServiceApi::Dataset' do
  before do
    VCR.insert_cassette name, record: :new_episodes
    @dataset = DataServicesApi::Service.new.dataset('ukhpi')
  end

  after do
    VCR.eject_cassette
  end

  # This feature is currently unavailable from SAPINT
  # it 'should have an id' do
  #   _(@dataset.id).wont_be_nil
  # end

  # This feature is currently unavailable from SAPINT
  # it 'should have a label' do
  #   _(@dataset.label).must_match(/UK house price index/)
  # end

  # This feature is currently unavailable from SAPINT
  # it 'should have a description' do
  #   _(@dataset.description).must_match(/A Data Cube of UK house price/)
  # end

  # This feature is currently unavailable from SAPINT
  # it 'should describe its own structure as a set of aspects' do
  #   # VCR.use_cassette( name, :record => :new_episodes) do
  #   structure = @dataset.structure
  #   _(structure).wont_be_nil
  #   _(structure).must_respond_to :size

  #   structure.each do |aspect|
  #     _(aspect.id).wont_be_nil
  #   end
  #   # end
  # end

  it 'should have a reference to the service object' do
    _(@dataset.service).wont_be_nil
    _(@dataset.service.url).wont_be_nil
  end

  it 'should accept a query and return the result' do
    query = { 'ukhpi:refRegion' => { '@eq' => { '@id' => 'http://landregistry.data.gov.uk/id/region/somerset' } } }
    json = @dataset.query(query)
    _(json).wont_be_nil
    _(json.size).must_be :>, 0
  end

  # This feature is currently unavailable from SAPINT
  # it 'should accept a URI and return an RDF description' do
  #   uri = 'http://landregistry.data.gov.uk/id/region/south-east'
  #   json = @dataset.describe(uri)
  #   _(json).wont_be_nil
  #   _(json['@graph'][0]['within']).must_include 'http://landregistry.data.gov.uk/id/region/england-and-wales'
  # end
end
