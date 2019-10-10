# frozen_string_literal: true

require './spec/minitest_helper'

describe 'DataServicesAPI::Service', vcr: true do
  before do
    VCR.insert_cassette name
    @service = DataServicesApi::Service.new
  end

  after do
    VCR.eject_cassette
  end

  it 'should return a list of defined datasets' do
    datasets = @service.datasets
    _(datasets).must_respond_to :size
    _(datasets.size).must_be :>=, 0
  end

  it 'should provide the identity of every dataset' do
    @service.datasets.each do |dataset|
      _(dataset).must_respond_to :id
      _(dataset.id).wont_be_nil
    end
  end

  it 'should find a dataset by name' do
    dataset = @service.dataset('ukhpi')
    _(dataset.id).must_equal 'http://landregistry.data.gov.uk/dsapi/hpi#ukhpi'
  end
end
