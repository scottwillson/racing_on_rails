# frozen_string_literal: true

message = nil
count = 0
posts_count = Post.count

MailingList.transaction do
  File.readlines(ARGV.last).each do |line|
    if line.match?(/\AFrom /)
      puts line
      MailingListMailer.receive(message) if message.present?
      message = ""
      count += 1
    else
      message << line.sub(/^>From/, "From")
    end
  rescue StandardError => e
    puts "#{e}: #{line}"
  end

  puts "Read #{count} messages. Created #{Post.count - posts_count} posts."

  raise(ActiveRecord::Rollback) if ENV["DOIT"].blank?
end
