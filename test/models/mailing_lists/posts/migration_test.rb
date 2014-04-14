require_relative "../../../test_helper"

# :stopdoc:
module Posts
  class MigrationTest < ActiveSupport::TestCase
    test "reposition! empty mailing list" do
      mailing_list = FactoryGirl.create(:mailing_list)
      Post.reposition! mailing_list
    end

    test "reposition!" do
      mailing_list = FactoryGirl.create(:mailing_list)
      one_day_ago = 1.day.ago
      last_original = FactoryGirl.create(
        :post,
        mailing_list: mailing_list,
        subject: "For Sale: Trek Madrone",
        date: 2.days.ago,
        last_reply_at: one_day_ago,
        position: 0
      )
      first_original = FactoryGirl.create(
        :post,
        mailing_list: mailing_list,
        subject: "Autographed TDF Jersey",
        date: 4.days.ago,
        last_reply_at: 4.days.ago,
        position: 2
      )
      reply_to_last_original = FactoryGirl.create(
        :post,
        mailing_list: mailing_list,
        subject: "re: For Sale: Trek Madrone",
        date: one_day_ago,
        last_reply_at: one_day_ago,
        position: 3
      )

      Post.reposition! mailing_list

      assert_equal 1, first_original.reload.position, "first post should be repositioned to position 1"
      assert_equal 2, reply_to_last_original.reload.position, "last post should be repositioned to position 2"
      assert_equal 3, last_original.reload.position, "last post should be repositioned to position 3"
    end

    test "add_replies! empty database" do
      mailing_list = FactoryGirl.create(:mailing_list)
      Post.add_replies! mailing_list
      assert_equal 0, Post.count
    end

    test "add_replies!" do
      mailing_list = FactoryGirl.create(:mailing_list)
      FactoryGirl.create(:post, mailing_list: mailing_list, subject: "For Sale: Trek Madrone", from_name: "Lance")
      FactoryGirl.create(:post, mailing_list: mailing_list, subject: "Autographed TDF Jersey")

      Post.add_replies! mailing_list
      assert_equal 2, Post.original.count
    end

    test "add_replies! should consolidate similar posts" do
      mailing_list = FactoryGirl.create(:mailing_list)
      original = FactoryGirl.create(:post, mailing_list: mailing_list, subject: "FS: Trek Madrone", date: 3.days.ago)
      first_reply = FactoryGirl.create(:post, mailing_list: mailing_list, subject: "Re: FS: Trek Madrone", date: 2.days.ago)
      second_reply = FactoryGirl.create(:post, mailing_list: mailing_list, subject: "fs: trek madrone", date: 1.day.ago)

      Post.add_replies! mailing_list

      assert_equal original, first_reply.reload.original, "should set original post"
      assert_equal original, second_reply.reload.original, "should set original post"
      assert_equal [ first_reply, second_reply ].sort, original.replies(true).sort, "replies"
      assert_equal second_reply.date, original.reload.last_reply_at, "original last_reply_at"
      assert_equal second_reply.from_name, original.reload.last_reply_from_name, "original last_reply_from_name"
    end
  end
end
