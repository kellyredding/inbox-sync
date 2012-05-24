require 'assert'

require 'inbox-sync/sync'
require 'inbox-sync/config'

module InboxSync

  class SyncTests < Assert::Context
    desc "a sync"
    before do
      @sync = InboxSync::Sync.new
      @raw_config = InboxSync::Config.new({
       :source => { :host => 'imap.test.com'}
      })
    end
    subject { @sync }

    should have_readers :config, :source_imap, :dest_imap, :notify_smtp
    should have_instance_methods :logged_in?, :logger
    should have_instance_method  :configure
    should have_instance_methods :login, :logout
    should have_instance_method  :each_source_mail_item
    should have_instance_method  :append_to_dest
    should have_instance_method  :archive_from_source
    # TODO: should have_instance_method  :apply_dest_filters
    # TODO: should have_instance_method  :notify

    should "configure using a block" do
      subject.configure do
        source.host 'imap.test.com'
      end
      assert_equal @raw_config.source, subject.config.source
    end

    should "configure passing in a settings hash" do
      a_sync = InboxSync::Sync.new({
        :source => {:host => 'imap.test.com'}
      })

      assert_equal a_sync.config.source, @raw_config.source
    end

    should "return itself when calling `configure`" do
      assert_equal subject, subject.configure
    end

  end

  class ConfiguredTests < SyncTests
    desc "that has been configured"

    before do
      @sync = configured_sync
    end

    after do
      @sync.logout if @sync.logged_in?
    end

  end

  class LoginLogoutTests < ConfiguredTests
    should "be able to login" do
      assert subject.login
      assert subject.logged_in?
    end

    should "be able to logout" do
      assert subject.logout
      assert_not subject.logged_in?
    end

    should "set IMAP and SMTP objects after login" do
      subject.login

      assert_kind_of Net::IMAP, subject.source_imap
      assert_kind_of Net::IMAP, subject.dest_imap
      assert_kind_of Net::SMTP, subject.notify_smtp
    end

    should "remove IMAP and SMTP objects after logout" do
      subject.logout

      assert_nil subject.source_imap
      assert_nil subject.dest_imap
      assert_nil subject.notify_smtp
    end

    should "validate the configs before logging in" do
      assert_raises ArgumentError do
        InboxSync::Sync.new.login
      end
    end

  end

  class LoggedInTests < ConfiguredTests
    desc 'and is logged in'
    before do
      @sync.login
    end

  end

  class AppendTests < LoggedInTests
    should "append a source msg onto the dest" do
      assert_nothing_raised do
        @sync.append_to_dest(test_mail_item)
      end
    end

    should "parse the destination UID when appending mail items" do
      assert_match /\A\d+\Z/, @sync.append_to_dest(test_mail_item)
    end
  end

  class ArchiveTests < LoggedInTests
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

    should "remove the message from the inbox" do
      @sync.archive_from_source(@mail_item)

      assert_not_included @mail_item.uid, @sync.source_imap.uid_search(['ALL'])
      assert_empty @sync.source_imap.uid_search(['ALL'])
    end

    should "move it to the archive folder" do
      @sync.archive_from_source(@mail_item)
      @sync.source_imap.select(@sync.config.archive_folder)

      assert_equal 1, @sync.source_imap.uid_search(['ALL']).size
    end

    should "not archive if no archive folder configured" do
      @sync.config.archive_folder = nil
      @sync.archive_from_source(@mail_item)
      @sync.source_imap.select(@sync.config.source.inbox)

      assert_not_included @mail_item.uid, @sync.source_imap.uid_search(['ALL'])
    end

  end

end
