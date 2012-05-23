require 'assert'

require 'inbox-syncro/sync'
require 'inbox-syncro/config'

module InboxSyncro

  class SynceTests < Assert::Context
    before do
      @sync = InboxSyncro::Sync.new
      @raw_config = InboxSyncro::Config.new({
       :source => { :host => 'imap.test.com'}
      })
    end
    subject { @sync }

    should have_readers :config, :source_imap, :dest_imap, :notify_smtp
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
      assert_equal @raw_config, subject.config
    end

    should "configure passing in a settings hash" do
      a_sync = InboxSyncro::Sync.new({
        :source => {:host => 'imap.test.com'}
      })

      assert_equal a_sync.config, @raw_config
    end

  end

end