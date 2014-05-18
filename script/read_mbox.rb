message = nil
count = 0
posts_count = Post.count

MailingList.transaction do
  File.readlines(ARGV[0]).each do |line|
    begin
      if (line.match(/\AFrom /))
        puts line
        MailingListMailer.receive(message) if message.present?
        message = ''
        count = count + 1
      else
        message << line.sub(/^\>From/, 'From')
      end
    rescue StandardError => e
      puts "#{e}: #{line}"
    end
  end

  puts "Read #{count} messages. Created #{Post.count - posts_count} posts."

  raise(ActiveRecord::Rollback) unless ENV["DOIT"].present?
end
