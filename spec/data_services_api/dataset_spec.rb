require './spec/minitest_helper'

describe 'DataServiceApi::Dataset' do
  before do
    VCR.insert_cassette name, record: :new_episodes
    @dataset = DataServicesApi::Service.new.dataset('ukhpi')
  end

  after do
    VCR.eject_cassette
  end

  it 'should have an id' do
    @dataset.id.wont_be_nil
  end

  it 'should have a label' do
    @dataset.label.must_match(/UK house price index/)
  end

  it 'should have a description' do
    @dataset.description.must_match(/A Data Cube of UK house price/)
  end

  it 'should describe its own structure as a set of aspects' do
    # VCR.use_cassette( name, :record => :new_episodes) do
    structure = @dataset.structure
    structure.wont_be_nil
    structure.must_respond_to :size

    structure.each do |aspect|
      aspect.id.wont_be_nil
    end
    # end
  end

  it 'should have a reference to the service object' do
    @dataset.service.wont_be_nil
    @dataset.service.url.wont_be_nil
  end

  it 'should accept a query and return the result' do
    query = { 'ukhpi:refRegion' => { '@eq' => { '@id' => 'http://landregistry.data.gov.uk/id/region/somerset' } } }
    json = @dataset.query(query)
    json.wont_be_nil
    json.size.must_be :>, 0
  end

  it 'should accept a URI and return an RDF description' do
    uri = 'http://landregistry.data.gov.uk/id/region/south-east'
    json = @dataset.describe(uri)
    json.wont_be_nil
    json['@graph'][0]['within'].must_include 'http://landregistry.data.gov.uk/id/region/england-and-wales'
  end
end
