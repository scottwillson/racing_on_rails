#!/usr/bin/env ruby

require 'net/http'

if ARGV[1] == "parse"
  File.open("urls",  "w") do |urls|
    Dir["/Users/sw/logs/*"].each do |path|
      File.readlines(path).each do |line|
        url = line[/\[(http:\/\/[^\]]+)/, 1]
        if url
          urls << url
          urls << "\n"
        end
      end
    end
  end
end

File.open("history",  "w") do |history|
  File.readlines("urls").each do |line|
    url = URI.parse(line.gsub(/app.obra.org|list.obra.org/, "0.0.0.0:3000"))
    if url.host == "0.0.0.0"
      req = Net::HTTP::Get.new(url.path)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.read_timeout = 600
        http.request(req)
      }
      memory = `ps aux | grep mongrel | grep -v grep`
      memory = memory[/\w+[ ]+\d+[ ]+\d+.\d+[ ]+\d+.\d+[ ]+\d+[ ]+(\d+)/, 1]
      history << "#{memory} #{url}\n"
    end
  end
end
