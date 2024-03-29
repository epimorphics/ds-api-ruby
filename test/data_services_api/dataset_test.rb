# frozen_string_literal: true

require './test/minitest_helper'

describe 'DataServiceApi::Dataset' do
  before do
    VCR.insert_cassette name, record: :new_episodes
    api_url = ENV['API_URL'] || 'http://localhost:8888'
    @dataset = DataServicesApi::Service.new(url: api_url).dataset('ukhpi')
  end

  after do
    VCR.eject_cassette
  end

  it 'should have a reference to the service object' do
    _(@dataset.service).wont_be_nil
    _(@dataset.service.url).wont_be_nil
  end

  it 'should accept a query and return the result' do
    query = Class.new do
      def terms
        { '@and' => [{ 'ukhpi:refMonth' => { '@ge' => { :@value => '2019-01', :@type => 'http://www.w3.org/2001/XMLSchema#gYearMonth' } } }, { 'ukhpi:refRegion' => { '@eq' => { :@id => 'http://landregistry.data.gov.uk/id/region/united-kingdom' } } }], '@sort' => [{ '@down' => 'ukhpi:refMonth' }], '@limit' => 1 }
      end

      def to_json(*_args)
        terms.to_json
      end
    end.new

    json = @dataset.query(query)
    _(json).wont_be_nil
    _(json.size).must_be :>, 0
  end
end
