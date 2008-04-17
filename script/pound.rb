#!/usr/bin/env ruby

require 'net/http'

url = ARGV[0]
count = ARGV[1]

url = URI.parse(url)

if count == '' || count.nil?
  count = 1
else
  count = count.to_i
end

count.times do
  req = Net::HTTP::Get.new(url.path)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.read_timeout = 600
    http.request(req)
  }
  memory = `ps aux | grep script/server | grep -v grep`
  memory = memory[/\w+[ ]+\d+[ ]+\d+.\d+[ ]+\d+.\d+[ ]+\d+[ ]+(\d+)/, 1]
  p "#{memory} #{url}\n"
end
