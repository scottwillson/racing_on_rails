class GoogleGroupManager
  def initialize
    key_path = "/var/www//rails/project-obra-chat-47a9a587c276.json"
    @service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    @key_data = JSON.parse(File.read(key_path))
    @service.authorization = authorize_service
  end

  def add_member(group, member_email)
    member = Google::Apis::AdminDirectoryV1::Member.new(
      email: member_email,
      role: "MEMBER"
    )
    @service.insert_member(group, member)
    puts "Added #{member_email} to #{group}"
  rescue Google::Apis::Error => e
    puts "Error: #{e.message}"
    puts "Error details: #{e.body}" if e.respond_to?(:body)
  end

  def remove_member(group, member_email)
    @service.delete_member(group, member_email)
    puts "Removed #{member_email} from #{group}"
  rescue Google::Apis::Error => e
    puts "Error: #{e.message}"
    puts "Error details: #{e.body}" if e.respond_to?(:body)
  end

  def group_emails(group)
    emails = []
    page_token = nil
    begin
      response = @service.list_members(
        group,
        page_token: page_token,
        max_results: 200  # Adjust as needed
      )
      if response.members
        emails += response.members.map(&:email)
      end
      page_token = response.next_page_token
    end while page_token
    emails
  rescue Google::Apis::Error => e
    puts "Error: #{e.message}"
    puts "Error details: #{e.body}" if e.respond_to?(:body)
    []
  end

  def code_red
    bad = 0
    good = 0
    added = 0
    emails = group_emails("obra-chat@obra.org")
    accounted = []
    emails.each do |email|
      if Person.where(email: email, member_to: Date.today..).any?
        puts "good #{email}"
        good += 1
        accounted << email
      else
        puts "bad #{email}"
        bad += 1
        # remove_member("obra-chat@obra.org", email)
      end
    end
    pp "good #{good} bad #{bad} of #{emails.count}"
    Person.where(member_to: Date.today..).where.not(email: [nil, ""]).each do |new|
      added += 1
      puts "added #{new.email}"
      add_member("obra-chat@obra.org", new.email)
    end
    pp added
  end

  private

  def authorize_service
    auth_client = Signet::OAuth2::Client.new(
      token_credential_uri: "https://oauth2.googleapis.com/token",
      audience: "https://oauth2.googleapis.com/token",
      scope: "https://www.googleapis.com/auth/admin.directory.group",
      issuer: @key_data["client_email"],
      signing_key: OpenSSL::PKey::RSA.new(@key_data["private_key"]),
      sub: "shillson@obra.org"
    )
    auth_client.fetch_access_token!
    auth_client
  end
end
