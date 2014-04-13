#!/usr/bin/env ruby

require "fileutils"

FileUtils.rm_rf("mailman")
FileUtils.mkdir("mailman")

lines = File.readlines("email")

body = []
index = 0
lines.each do |line|
  if body.size > 0 && line[/^From /]
    p line
    File.open("mailman/#{index}.txt", "w") do |file|
      body.each { |l| file.puts(l) }
    end

    index = index + 1
    body = []
  end
  body << line
end

Dir["mailman/*.txt"].each do |email|
  system("cat #{email} | /usr/local/www/rails/obra/current/script/runner -e 'production' 'MailingListMailer.receive(STDIN.read)'")
end
