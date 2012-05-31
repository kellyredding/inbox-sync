require 'assert'

require 'inbox-sync/sync'
require 'inbox-sync/config'

module InboxSync

  class BasicSyncTests < Assert::Context
    desc "a sync"
    before do
      @sync = InboxSync::Sync.new
      @raw_config = InboxSync::Config.new({
       :source => { :host => 'imap.test.com'}
      })
    end
    subject { @sync }

    should have_readers :config, :source_imap, :notify_smtp
    should have_instance_methods :logged_in?, :logger
    should have_instance_method  :configure, :setup, :teardown, :run

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

end
