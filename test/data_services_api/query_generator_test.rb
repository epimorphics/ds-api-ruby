# frozen_string_literal: true

require './test/minitest_helper'

describe 'DataServiceApi::QueryGenerator' do
  before do
    VCR.insert_cassette name, record: :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  def conjunction(term)
    { '@and' => term.is_a?(Hash) ? [term] : Array(term) }
  end

  it 'should start with an empty query' do
    pattern = {}
    query = DataServicesApi::QueryGenerator.new
    _(query.to_json).wont_be_nil
    _(query.to_json).must_match_json_expression pattern
  end

  it 'should allow adding an equality clause' do
    pattern = conjunction(foo: { '@eq' => 'bar' })

    query = DataServicesApi::QueryGenerator.new
                                           .eq('foo', 'bar')

    _(query.to_json).wont_be_nil
    _(query.to_json).must_match_json_expression pattern
  end

  it 'should allow adding a relational operator clause' do
    query = DataServicesApi::QueryGenerator.new

    _(query.ge('foo', 1).to_json).must_match_json_expression(conjunction(foo: { '@ge' => 1 }))
    _(query.gt('foo', 1).to_json).must_match_json_expression(conjunction(foo: { '@gt' => 1 }))
    _(query.le('foo', 1).to_json).must_match_json_expression(conjunction(foo: { '@le' => 1 }))
    _(query.lt('foo', 1).to_json).must_match_json_expression(conjunction(foo: { '@lt' => 1 }))
  end

  it 'should allow sorting to specified' do
    query = DataServicesApi::QueryGenerator.new
    _(query.sort(:up, 'foo').to_json).must_match_json_expression('@sort' => [{ '@up' => 'foo' }])
    _(query.sort(:up, 'foo').sort(:down, 'bar').to_json).must_match_json_expression('@sort' => [{ '@up' => 'foo' }, { '@down' => 'bar' }])
  end

  it 'should allow a range to be specified' do
    query = DataServicesApi::QueryGenerator.new

    _(query.le('foo', 10)
           .ge('foo', 1)
           .to_json)
      .must_match_json_expression(conjunction([{ foo: { '@ge' => 1 } }, { foo: { '@le' => 10 } }]))
  end

  it 'should allow an arbitrary relational operator to be added' do
    query = DataServicesApi::QueryGenerator.new
    _(query.op(:le, :foo, 1000)
           .op('@ge', :foo, 100)
           .to_json)
      .must_match_json_expression(conjunction([{ foo: { '@ge' => 100 } }, { foo: { '@le' => 1000 } }]))
  end

  it 'should reject an unknown relational operator' do
    _(proc {
      query = DataServicesApi::QueryGenerator.new
      query.op(:range, :foo, 1000)
    }).must_raise NameError
  end

  it 'should add a value type when required' do
    query = DataServicesApi::QueryGenerator.new
    _(query.op(:ge, :foo, Date.parse('2014-01-01'))
           .to_json)
      .must_match_json_expression(conjunction(foo: { '@ge' => { '@value' => '2014-01-01', '@type' => 'xsd:date' } }))
  end

  it 'should allow a text search option to be added' do
    query = DataServicesApi::QueryGenerator.new
    _(query.search('foo')
           .to_json)
      .must_match_json_expression(conjunction('@search' => 'foo'))
  end

  it 'should allow a text search against a specific property to be added' do
    query = DataServicesApi::QueryGenerator.new
    _(query.search_property('foo:bar', 'foo')
           .to_json)
      .must_match_json_expression(conjunction('@search' => { '@value' => 'foo', '@property' => 'foo:bar' }))
  end

  it 'should allow a text search against a specific aspect to be added' do
    query = DataServicesApi::QueryGenerator.new
    _(query.search_aspect('foo:aspect', 'foo')
           .to_json)
      .must_match_json_expression(conjunction('foo:aspect' => { '@search' => 'foo' }))
  end

  it 'should allow a text search against a specific property of an aspect to be added' do
    query = DataServicesApi::QueryGenerator.new
    _(query.search_aspect_property('foo:aspect', 'foo:bar', 'foo')
           .to_json)
      .must_match_json_expression(conjunction('foo:aspect' => { '@search' => { '@value' => 'foo', '@property' => 'foo:bar' } }))
  end

  it 'should allow the limit to be set on a search query' do
    query = DataServicesApi::QueryGenerator.new
    _(query.search_aspect_property('foo:aspect', 'foo:bar', 'foo', '@limit' => 997)
           .to_json)
      .must_match_json_expression(conjunction('foo:aspect' => { '@search' => { '@value' => 'foo',
                                                                               '@property' => 'foo:bar',
                                                                               '@limit' => 997 } }))
    _(query.search_property('foo:bar', 'foo', '@limit' => 779)
           .to_json)
      .must_match_json_expression(conjunction('@search' => { '@value' => 'foo',
                                                             '@property' => 'foo:bar',
                                                             '@limit' => 779 }))
  end

  it 'should allow a simple boolean expression to be added' do
    query = DataServicesApi::QueryGenerator.new
    _(query.eq_any_uri('foo:aspect', ['foo:bar', 'foo:bam'])
           .to_json)
      .must_match_json_expression(conjunction('foo:aspect' => { '@oneof' => [{ '@id' => 'foo:bar' }, { '@id' => 'foo:bam' }] }))

    _(query.eq_any_value('foo:aspect', ['foo:bar', 'foo:bam'])
           .to_json)
      .must_match_json_expression(conjunction('foo:aspect' => { '@oneof' => [{ '@value' => 'foo:bar' }, { '@value' => 'foo:bam' }] }))
  end

  it 'should allow a type to be specified for a boolean expression value' do
    query = DataServicesApi::QueryGenerator.new
    _(query.eq_any_value('foo:aspect', ['foo:bar', 'foo:bam'], type: 'xsd:coconut')
           .to_json)
      .must_match_json_expression(conjunction('foo:aspect' => { '@oneof' => [{ '@value' => 'foo:bar', '@type' => 'xsd:coconut' },
                                                                             { '@value' => 'foo:bam', '@type' => 'xsd:coconut' }] }))
  end

  it 'should allow a terms to be composed' do
    query = DataServicesApi::QueryGenerator.new
    _(query.eq('foo', 'bar')
         .eq('cat', 'cow')
         .search_aspect_property('foo:aspect', 'foo:bar', 'foo')
         .to_json)
      .must_match_json_expression(conjunction([
                                                { foo: { '@eq' => 'bar' } },
                                                { cat: { '@eq' => 'cow' } },
                                                { 'foo:aspect' => { '@search' => { '@value' => 'foo', '@property' => 'foo:bar' } } }
                                              ]))

    query = DataServicesApi::QueryGenerator.new
    _(query.search_aspect_property('foo:aspect', 'foo:bar', 'foo')
           .search_aspect_property('foo:aspect', 'foo:blom', 'fim')
           .to_json)
      .must_match_json_expression(conjunction([
                                                { 'foo:aspect' => { '@search' => { '@value' => 'foo', '@property' => 'foo:bar' } } },
                                                { 'foo:aspect' => { '@search' => { '@value' => 'fim', '@property' => 'foo:blom' } } }
                                              ]))
  end

  it 'should allow a regex match to be specified' do
    query = DataServicesApi::QueryGenerator.new
    _(query.matches('foo:aspect', 'bing.*')
           .to_json)
      .must_match_json_expression(conjunction('foo:aspect' => { '@matches' => 'bing.*' }))

    query = DataServicesApi::QueryGenerator.new
    _(query.matches('foo:aspect', 'bing.*', flags: 'i')
           .to_json)
      .must_match_json_expression(conjunction('foo:aspect' => { '@matches' => ['bing.*', 'i'] }))
  end

  it 'should allow an overall query limit to be set' do
    query = DataServicesApi::QueryGenerator.new
    _(query.limit(101)
           .offset(20)
           .to_json)
      .must_match_json_expression('@limit' => 101, '@offset' => 20)
  end

  it 'should allow a query to be run in count mode' do
    query = DataServicesApi::QueryGenerator.new
    _(query.count_only.to_json)
      .must_match_json_expression('@count' => true)
  end

  it 'should not share structure between queries' do
    query_base = DataServicesApi::QueryGenerator.new.le('foo:crivens', 42)

    query_base.eq('foo:test', '@id' => 'http://foo.bar')

    _(query_base.terms['@and'].size).must_equal 1
  end

  it 'should allow compact JSON to be specified' do
    query = DataServicesApi::QueryGenerator.new

    _(query.compact_json.to_json)
      .must_match_json_expression('@json_mode' => 'compact')
  end
end
