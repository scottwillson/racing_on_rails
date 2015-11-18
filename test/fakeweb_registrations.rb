FakeWeb.register_uri(
  :delete,
  %r{http://localhost:9200/*},
  body: { found: true, _index: "posts", _type: "post", _id: "2", _version: 5 }.to_json,
  content_type: "application/json; charset=UTF-8"
)

FakeWeb.register_uri(
  :get,
  %r{http://localhost:9200/*},
  body: { took: 2, timed_out: false, _shards: { total: 5, successful: 5, failed: 0 }, hits: { total: 0, max_score: nil, hits: [] } }.to_json,
  content_type: "application/json; charset=UTF-8"
)

FakeWeb.register_uri(
  :post,
  %r{http://localhost:9200/*},
  body: { _index: "posts", _type: "post", _id: "1", _version: 136 }.to_json,
  content_type: "application/json; charset=UTF-8"
)

FakeWeb.register_uri(
  :put,
  %r{http://localhost:9200/*},
  body: { _index: "posts", _type: "post", _id: "1", _version: 118, created: false }.to_json,
  content_type: "application/json; charset=UTF-8"
)

FakeWeb.allow_net_connect = %r[\Ahttp(s?)://(localhost|127.0.0.1|0.0.0.0|codeclimate.com)]
