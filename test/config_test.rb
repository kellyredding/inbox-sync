require 'assert'
require 'ns-options/assert_macros'

require 'inbox-sync/config'

module InboxSync

  class ConfigTests < Assert::Context
    include NsOptions::AssertMacros

    before do
      @config = InboxSync::Config.new
    end
    subject { @config }

    should have_option :source, InboxSync::Config::IMAPConfig, {
      :default => {},
      :required => true
    }

    should have_option :dest,   InboxSync::Config::IMAPConfig, {
      :default => {},
      :required => true
    }

    should have_option :notify, InboxSync::Config::SMTPConfig, {
      :default => {},
      :required => true
    }

    should have_option :archive_folder, {
      :default => "Forwarded",
      :required => true
    }

    should have_instance_method  :validate!

    should "complain if missing :source config" do
      assert_raises ArgumentError do
        subject.source = nil
        subject.validate!
      end
    end

    should "complain if missing :dest config" do
      assert_raises ArgumentError do
        subject.dest = nil
        subject.validate!
      end
    end

    should "complain if missing :notify config" do
      assert_raises ArgumentError do
        subject.notify = nil
        subject.validate!
      end
    end

    should "complain if missing :archive_folder config" do
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

  class CredentialsTests < ConfigTests
    subject { @config.source.login }

    should have_option :user, :required => true
    should have_option :pw, :required => true

    should have_instance_method :validate!

    should "complain if missing :user config" do
      assert_raises ArgumentError do
        subject.user = nil
        subject.validate!
      end
    end

    should "complain if missing :pw config" do
      assert_raises ArgumentError do
        subject.pw = nil
        subject.validate!
      end
    end

    should "be built from set of args" do
      cred = InboxSync::Config::Credentials.new 'me', 'secret'

      assert_equal 'me',     cred.user
      assert_equal 'secret', cred.pw
    end

  end

  class IMAPConfigTests < ConfigTests
    subject { @config.source }

    should have_option :host, :required => true

    should have_option :port, {
      :default => 143,
      :required => true
    }

    should have_option :ssl, NsOptions::Boolean, {
      :default => false,
      :required => true
    }

    should have_option :login, InboxSync::Config::Credentials, {
      :default => {},
      :required => true
    }

    should have_option :inbox, {
      :default => "INBOX",
      :required => true
    }

    should have_option :expunge, NsOptions::Boolean, {
      :default => true,
      :required => true
    }

    should "complain if missing :host config" do
      assert_raises ArgumentError do
        subject.host = nil
        subject.validate!
      end
    end

    should "complain if missing :port config" do
      assert_raises ArgumentError do
        subject.port = nil
        subject.validate!
      end
    end

    should "complain if missing :ssl config" do
      assert_raises ArgumentError do
        subject.ssl = nil
        subject.validate!
      end
    end

    should "complain if missing :login config" do
      assert_raises ArgumentError do
        subject.login = nil
        subject.validate!
      end
    end

    should "complain if missing :inbox config" do
      assert_raises ArgumentError do
        subject.inbox = nil
        subject.validate!
      end
    end

    should "complain if missing :host config" do
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

    should have_option :login, InboxSync::Config::Credentials, {
      :default => {},
      :required => true
    }

    should have_option :authtype, {
      :default => :login,
      :required => true
    }

    should have_option :to_addrs, :required => true

    should have_instance_method  :validate!

    should "complain if missing :host config" do
      assert_raises ArgumentError do
        subject.host = nil
        subject.validate!
      end
    end

    should "complain if missing :port config" do
      assert_raises ArgumentError do
        subject.port = nil
        subject.validate!
      end
    end

    should "complain if missing :tls config" do
      assert_raises ArgumentError do
        subject.tls = nil
        subject.validate!
      end
    end

    should "complain if missing :helo config" do
      assert_raises ArgumentError do
        subject.helo = nil
        subject.validate!
      end
    end

    should "complain if missing :login config" do
      assert_raises ArgumentError do
        subject.login = nil
        subject.validate!
      end
    end

    should "complain if missing :authtype config" do
      assert_raises ArgumentError do
        subject.authtype = nil
        subject.validate!
      end
    end

    should "complain if missing :to_addrs config" do
      assert_raises ArgumentError do
        subject.to_addrs = nil
        subject.validate!
      end
    end

    should "complain if empty :to_addrs config" do
      assert_raises ArgumentError do
        subject.to_addrs = []
        subject.validate!
      end
    end


  end

end
