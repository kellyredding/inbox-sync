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
    should have_instance_method  :source_mail
    should have_instance_method  :append_to_dest
    # TODO: should have_instance_method  :apply_dest_filters
    # TODO: should have_instance_method  :notify
    should have_instance_method  :archive_source

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

end
