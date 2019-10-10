# frozen_string_literal: true

require './spec/minitest_helper'

describe 'DataServiceApi::Aspect' do
  before do
    VCR.insert_cassette name, record: :new_episodes
    @aspects = DataServicesApi::Service.new.dataset('ukhpi').structure
    @aspect1 = @aspects[0]
  end

  after do
    VCR.eject_cassette
  end

  it 'should have a name' do
    _(@aspect1.name).wont_be_nil
    _(@aspect1.name).wont_match(/^http:/)
  end

  it 'should have a URI' do
    _(@aspect1.uri).must_match(/^http:/)
  end

  it 'should have an ID' do
    _(@aspect1.id).must_match(/^http:/)
  end

  it 'should have a label' do
    _(@aspect1.label).must_match(/.+/)
  end

  it 'should have a description' do
    _(@aspect1.description).must_match(/.+/)
  end

  it 'should not be optional' do
    _(@aspect1.optional?).must_equal true
  end

  it 'should not be multi-valued' do
    _(@aspect1.multi_valued?).must_equal false
  end

  it 'should have a range type' do
    _(@aspect1.range_type).must_match(%r{http://www.w3.org/2001/XMLSchema#})
  end

  it 'should have a reference to the service object' do
    _(@aspect1.service).wont_be_nil
    _(@aspect1.service.url).wont_be_nil
  end
end
