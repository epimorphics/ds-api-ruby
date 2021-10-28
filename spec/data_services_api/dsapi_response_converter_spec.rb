# frozen_string_literal: true

require './spec/minitest_helper'

describe 'DataServicesApi::DSAPIResponseConverter' do
  describe 'PPD' do
    let(:ppd_sapint_items) do
      [
        {
          '@id' => 'http://landregistry.data.gov.uk/data/ppi/transaction/F799167A-933D-4A33-8823-01CB7CFD43BB/current',
          'propertyAddress' => {
            '@id' => 'http://landregistry.data.gov.uk/data/ppi/address/4c03e3251cddc45cb6bbeeed2524805be5c75c6b',
            'county' => 'SOUTH YORKSHIRE',
            'district' => 'SHEFFIELD',
            'locality' => 'SOTHALL',
            'paon' => '5',
            'postcode' => 'S20 2QW',
            'street' => 'MILBURN COURT',
            'town' => 'SHEFFIELD'
          },
          'newBuild' => false,
          'estateType' => { '@id' => 'http://landregistry.data.gov.uk/def/common/freehold' },
          'transactionCategory' => { '@id' => 'http://landregistry.data.gov.uk/def/ppi/standardPricePaidTransaction' },
          'pricePaid' => 41_950,
          'transactionDate' => '1995-06-30',
          'propertyType' => { '@id' => 'http://landregistry.data.gov.uk/def/common/semi-detached' },
          'hasTransaction' => { '@id' => 'http://landregistry.data.gov.uk/data/ppi/transaction/F799167A-933D-4A33-8823-01CB7CFD43BB' },
          'transactionId' => 'F799167A-933D-4A33-8823-01CB7CFD43BB',
          'recordStatus' => { '@id' => 'http://landregistry.data.gov.uk/def/ppi/add' }
        }
      ]
    end

    let(:ppd_dsapi_items) do
      [
        {
          'ppd:propertyAddressPostcode' => 'S20 2QW',
          'ppd:transactionCategory' => 'http://landregistry.data.gov.uk/def/ppi/standardPricePaidTransaction',
          'ppd:propertyAddressCounty' => 'SOUTH YORKSHIRE',
          'ppd:estateType' => 'http://landregistry.data.gov.uk/def/common/freehold',
          'ppd:propertyAddressPaon' => '5',
          'ppd:recordStatus' => 'http://landregistry.data.gov.uk/def/ppi/add',
          'ppd:propertyAddressStreet' => 'MILBURN COURT',
          'ppd:transactionId' => 'F799167A-933D-4A33-8823-01CB7CFD43BB',
          'ppd:propertyAddressTown' => 'SHEFFIELD',
          'ppd:pricePaid' => 41_950,
          'ppd:propertyAddressLocality' => 'SOTHALL',
          'ppd:hasTransaction' => 'http://landregistry.data.gov.uk/data/ppi/transaction/F799167A-933D-4A33-8823-01CB7CFD43BB',
          'ppd:transactionDate' => '1995-06-30',
          'ppd:propertyAddress' => 'http://landregistry.data.gov.uk/data/ppi/address/4c03e3251cddc45cb6bbeeed2524805be5c75c6b',
          '@id' => 'http://landregistry.data.gov.uk/data/ppi/transaction/F799167A-933D-4A33-8823-01CB7CFD43BB/current',
          'ppd:newBuild' => false,
          'ppd:propertyAddressDistrict' => 'SHEFFIELD',
          'ppd:propertyType' => 'http://landregistry.data.gov.uk/def/common/semi-detached'
        }
      ]
    end

    let(:ppd_resp_conv) do
      DataServicesApi::DSAPIResponseConverter.new(
        {
          'items' => ppd_sapint_items
        },
        'ppd',
        json_mode_compact: true
      )
    end

    it 'should convert the SAPINT response format to DSAPI response format' do
      _(ppd_resp_conv.to_dsapi_response).must_equal ppd_dsapi_items
    end

    it 'should convert one SAPINT item to DSAPI format' do
      _(ppd_resp_conv.send(:to_dsapi_item, ppd_sapint_items[0])).must_equal ppd_dsapi_items[0]
    end

    it 'should convert some SAPINT json to DSAPI format' do
      actual_response = ppd_resp_conv.send(:to_dsapi_json, 'newBuild', ppd_sapint_items[0]['newBuild'])
      expected_response = { 'ppd:newBuild' => ppd_dsapi_items[0]['ppd:newBuild'] }
      _(actual_response).must_equal expected_response
    end

    it 'should convert SAPINT hash to DSAPI format' do
      actual_response = ppd_resp_conv.send(:to_dsapi_json, 'propertyAddress', 'county' => 'SOMERSET')
      expected_response = { 'ppd:propertyAddressCounty' => 'SOMERSET' }
      _(actual_response).must_equal expected_response
    end
  end
