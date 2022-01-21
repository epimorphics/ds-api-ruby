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

  it 'should find a dataset by name' do
    dataset = @service.dataset('ukhpi')
    _(dataset.data_api).must_match %r{/landregistry/id/ukhpi}
  end
end
