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
end
