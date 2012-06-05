require 'assert'

require 'inbox-sync/sync'

module InboxSync

  class ConfiguredSyncTests < Assert::Context
    desc "a sync that has been configured and setup"
    before do
      @sync = configured_sync
      @sync.setup
    end
    after do
      @sync.teardown
    end
    subject { @sync }

    should "be logged in" do
      assert subject.logged_in?
    end

    should "be logged out after teardown" do
      subject.teardown

      assert_not subject.logged_in?
    end

    should "set source IMAP and notify SMTP objects" do
      assert_kind_of Net::IMAP, subject.source_imap
      assert_kind_of Net::SMTP, subject.notify_smtp
    end

    should "remove source IMAP and notify SMTP objects after teardown" do
      subject.teardown

      assert_nil subject.source_imap
      assert_nil subject.notify_smtp
    end

    should "validate the configs on setup" do
      assert_raises ArgumentError do
        InboxSync::Sync.new(:logger => '/dev/null').setup
      end
    end

  end

  class LoggedInTests < ConfiguredSyncTests
    desc 'and is logged in and ready to run'
    before do
      reset_source_inbox(@sync)
      reset_source_archive(@sync)

      @sync_archive_folder = @sync.config.archive_folder
      @mail_item = MailItem.find(@sync.source_imap).first
    end

    after do
      @sync.config.archive_folder = @sync_archive_folder
      @sync.source_imap.select(@sync.config.source.inbox)

      reset_source_archive(@sync)
    end

    should "run without any errors" do
      assert_nothing_raised do
        subject.run
      end
    end

  end

  # class ArchiveTests < RunTests
  #   should "remove the message from the inbox" do
  #     @sync.archive_from_source(@mail_item)

  #     assert_not_included @mail_item.uid, @sync.source_imap.uid_search(['ALL'])
  #     assert_empty @sync.source_imap.uid_search(['ALL'])
  #   end

  #   should "move it to the archive folder" do
  #     @sync.archive_from_source(@mail_item)
  #     @sync.source_imap.select(@sync.config.archive_folder)

  #     assert_equal 1, @sync.source_imap.uid_search(['ALL']).size
  #   end

  #   should "not archive if no archive folder configured" do
  #     @sync.config.archive_folder = nil
  #     @sync.archive_from_source(@mail_item)
  #     @sync.source_imap.select(@sync.config.source.inbox)

  #     assert_not_included @mail_item.uid, @sync.source_imap.uid_search(['ALL'])
  #   end

  # end

  # class AppendTests < LoggedInTests
  #   should "append a source msg onto the dest" do
  #     assert_nothing_raised do
  #       @sync.append_to_dest(test_mail_item)
  #     end
  #   end

  #   should "parse the destination UID when appending mail items" do
  #     assert_match /\A\d+\Z/, @sync.append_to_dest(test_mail_item)
  #   end
  # end

end
