require 'assert'
require 'ns-options/assert_macros'

require 'inbox-syncro/config'

module InboxSyncro

  class ConfigTests < Assert::Context
    include NsOptions::AssertMacros

    before do
      @config = InboxSyncro::Config.new
    end
    subject { @config }

    should have_option :source, InboxSyncro::Config::IMAPConfig, {
      :default => {},
      :required => true
    }

    should have_option :dest,   InboxSyncro::Config::IMAPConfig, {
      :default => {},
      :required => true
    }

    should have_option :notify, InboxSyncro::Config::SMTPConfig, {
      :default => {},
      :required => true
    }

    should have_option :archive_folder, {
      :default => "Forwarded",
      :required => true
    }

    should have_instance_method  :validate!

    should "complain if missing required configs" do
      assert_raises ArgumentError do
        subject.source = nil
        subject.validate!
      end

      assert_raises ArgumentError do
        subject.dest = nil
        subject.validate!
      end

      assert_raises ArgumentError do
        subject.notify = nil
        subject.validate!
      end

      assert_raises ArgumentError do
        subject.archive_folder = nil
        subject.validate!
      end
    end

    should "validate its source" do
      assert_raises ArgumentError do
        subject.source.host = nil
        subject.validate!
      end
    end

    should "validate its dest" do
      assert_raises ArgumentError do
        subject.dest.host = nil
        subject.validate!
      end
    end

    should "validate its notify" do
      assert_raises ArgumentError do
        subject.notify.host = nil
        subject.validate!
      end
    end

  end

  class IMAPConfigTests < ConfigTests
    before do
      @source = @config.source
    end
    subject { @source }

    should have_option :host, :required => true

    should have_option :port, {
      :default => 143,
      :required => true
    }

    should have_option :ssl, NsOptions::Boolean, {
      :default => false,
      :required => true
    }

    should have_instance_method  :login
    should "have a namespace for login info" do
      assert_kind_of NsOptions::Namespace, subject.login

      assert_respond_to :user, subject.login
      assert_respond_to :pw, subject.login

      assert_nil subject.login.user
      assert_nil subject.login.pw
    end


    should have_option :inbox, {
      :default => "INBOX",
      :required => true
    }

    should have_option :expunge, NsOptions::Boolean, {
      :default => true,
      :required => true
    }

    should "complain if missing required configs" do
      assert_raises ArgumentError do
        subject.host = nil
        subject.validate!
      end

      assert_raises ArgumentError do
        subject.port = nil
        subject.validate!
      end

      assert_raises ArgumentError do
        subject.ssl = nil
        subject.validate!
      end

      assert_raises ArgumentError do
        subject.login.user = nil
        subject.validate!
      end

      assert_raises ArgumentError do
        subject.login.pw = nil
        subject.validate!
      end

      assert_raises ArgumentError do
        subject.inbox = nil
        subject.validate!
      end

      assert_raises ArgumentError do
        subject.expunge = nil
        subject.validate!
      end
    end

  end

  class SMTPConfigTests < ConfigTests
    subject { @config.notify }

    should have_option :host, :required => true

    should have_option :port, {
      :default => 587,
      :required => true
    }

    should have_option :tls,  NsOptions::Boolean, {
      :default => true,
      :required => true
    }

    should have_option :helo, :required => true

    should have_option :user, :required => true
    should have_option :pw, :required => true

    should have_option :authtype, {
      :default => :login,
      :required => true
    }

    should have_option :to_addrs, :required => true

    should have_instance_method  :validate!

    should "complain if missing required configs" do
      assert_raises ArgumentError do
        subject.host = nil
        subject.validate!
      end

      assert_raises ArgumentError do
        subject.port = nil
        subject.validate!
      end

      assert_raises ArgumentError do
        subject.tls = nil
        subject.validate!
      end

      assert_raises ArgumentError do
        subject.helo = nil
        subject.validate!
      end

      assert_raises ArgumentError do
        subject.user = nil
        subject.validate!
      end

      assert_raises ArgumentError do
        subject.pw = nil
        subject.validate!
      end

      assert_raises ArgumentError do
        subject.authtype = nil
        subject.validate!
      end

      assert_raises ArgumentError do
        subject.to_addrs = nil
        subject.validate!
      end

      assert_raises ArgumentError do
        subject.to_addrs = []
        subject.validate!
      end
    end


  end

end
