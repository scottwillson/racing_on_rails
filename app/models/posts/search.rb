module Posts
  module Search
    extend ActiveSupport::Concern

    included do
      include Elasticsearch::Model
      include Elasticsearch::Model::Callbacks

      settings do
        mappings dynamic: "false" do
          indexes [ :subject, :body, :from_email, :from_name, :date ], analyzer: "english", index_options: "offsets"
        end
      end

      def self.matching(mailing_list, subject)
        ActiveSupport::Notifications.instrument "search.posts.racing_on_rails", subject: subject do
          Post.search(
            query: {
              multi_match: {
                query: subject,
                fields: [ "subject^3", "body" ]
              }
            },
            filter: {
              term: { mailing_list_id: mailing_list.id }
            },
            sort: { last_reply_at: { order: "desc" } },
            size: 800,
            min_score: 2
          ).records.original.order("position desc")
        end
      end
    end
  end
end
