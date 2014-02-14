require './spec/minitest_helper'

require 'json'
require 'data_services_api/service'
require 'data_services_api/dataset'

describe "DataServicesAPI::Service", vcr: true do
  before do
    VCR.insert_cassette :service_spec
    @service = DataServicesApi::Service.new
  end

  after do
    VCR.eject_cassette :service_spec
  end


  it "should return a list of defined datasets" do
    datasets = @service.datasets
    datasets.must_respond_to :size
    datasets.size.must_be :>=, 0
  end

  it "should provide the identity of every dataset" do
    @service.datasets.each do |dataset|
      dataset.must_respond_to :id
      dataset.id.wont_be_nil
    end
  end

end
