require 'assert'
require 'mail'
require 'inbox-sync/mail_item'

module InboxSync

  class MailItemTests < Assert::Context
    desc 'a mail item'
    before do
      @item = test_mail_item
    end
    subject { @item }

    should have_readers :uid, :meta, :message
    should have_class_method :find

    should "build a Mail Message from the raw IMAP attr data" do
      assert_kind_of ::Mail::Message, subject.message
    end

    should "provide the raw IMAP attrs in the meta hash" do
      assert_includes 'RFC822', subject.meta
      assert_includes 'INTERNALDATE', subject.meta

      assert_equal TEST_MAIL_DATA['RFC822'], subject.meta['RFC822']
      assert_equal TEST_MAIL_DATA['INTERNALDATE'], subject.meta['INTERNALDATE']
    end

  end

end
