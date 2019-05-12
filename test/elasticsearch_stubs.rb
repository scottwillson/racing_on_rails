# frozen_string_literal: true

module ElasticsearchStubs
  def stub_elasticsearch
    WebMock.stub_request(:delete, %r{http://localhost:9200/*}).to_return(status: 200, body: String.new, headers: {})
    WebMock.stub_request(:put, %r{http://localhost:9200/*}).to_return(status: 200, body: String.new, headers: {})

    WebMock
      .stub_request(:get, %r{http://localhost:9200/*})
      .to_return(
        status: 200,
        body: { took: 2, timed_out: false, _shards: { total: 5, successful: 5, failed: 0 }, hits: { total: 0, max_score: nil, hits: [] } }.to_json,
        headers: { content_type: "application/json; charset=UTF-8" }
      )

    WebMock
      .stub_request(:post, %r{http://localhost:9200/*})
      .to_return(
        status: 200,
        body: { _index: "posts", _type: "post", _id: "1", _version: 136 }.to_json,
        headers: { content_type: "application/json; charset=UTF-8" }
      )
  end
end
