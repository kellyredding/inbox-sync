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

end
