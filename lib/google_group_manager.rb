require "google/apis/admin_directory_v1"
require "json"

class GoogleGroupManager
  def initialize(key_path, admin_email)
    @service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    @key_data = JSON.parse(File.read(key_path))
    @service.authorization = authorize_service(admin_email)
  end

  def add_member(group_email, member_email)
    member = Google::Apis::AdminDirectoryV1::Member.new(
      email: member_email,
      role: "MEMBER"
    )
    @service.insert_member(group_email, member)
    puts "Added #{member_email} to #{group_email}"
  rescue Google::Apis::Error => e
    puts "Error: #{e.message}"
    puts "Error details: #{e.body}" if e.respond_to?(:body)
  end

  def remove_member(group_email, member_email)
    @service.delete_member(group_email, member_email)
    puts "Removed #{member_email} from #{group_email}"
  rescue Google::Apis::Error => e
    puts "Error: #{e.message}"
    puts "Error details: #{e.body}" if e.respond_to?(:body)
  end

  private

  def authorize_service(admin_email)
    auth_client = Signet::OAuth2::Client.new(
      token_credential_uri: "https://oauth2.googleapis.com/token",
      audience: "https://oauth2.googleapis.com/token",
      scope: "https://www.googleapis.com/auth/admin.directory.group",
      issuer: @key_data["client_email"],
      signing_key: OpenSSL::PKey::RSA.new(@key_data["private_key"]),
      sub: admin_email  # Using workspace admin email
    )

    auth_client.fetch_access_token!
    auth_client
  end
end

# Usage
manager = GoogleGroupManager.new("project-obra-chat-3a59b8e24f78.json", "shillson@obra.org")
manager.remove_member("obra-chat@obra.org", "shillson@obra.org")
manager.add_member("obra-chat@obra.org", "shillson@obra.org")
