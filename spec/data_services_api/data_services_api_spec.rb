require './spec/minitest_helper'

describe 'DataServicesAPI', 'the data services API' do
  it 'should have a semantic version' do
    DataServicesApi::VERSION.must_match(/\d+\.\d+\.\d+/)
  end

  it 'should be constructable with a default URL' do
    dsapi = DataServicesApi::Service .new
    dsapi.url.must_match(%r{localhost:8080/dsapi})
  end

  it 'should be constructable with a given URL' do
    dsapi = DataServicesApi::Service .new(url: 'foo/bar')
    dsapi.url.must_match(%r{foo/bar})
  end
end
