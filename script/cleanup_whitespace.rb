#!/usr/bin/env ruby

Dir.glob("{app,config,lib,public,script,test,local}/**/*.{erb,js,css,scss,html,rb}").each do |path|
  lines = File.readlines(path)
  puts path
  File.open(path, "w") do |file|
    lines.each do |line|
      file << line.gsub(/[[:space:]]*\Z/, "")
      file << "\n"
    end
  end
end

