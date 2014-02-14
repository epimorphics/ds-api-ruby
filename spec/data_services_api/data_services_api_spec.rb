require './spec/minitest_helper'

describe "DataServicesAPI", "the data services API" do
  it "should have a version" do
    DataServicesApi::VERSION.must_match /\d+\.\d+\.\d+/
  end

end
