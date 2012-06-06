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

    should have_readers :imap, :uid
    should have_class_method :find
    should have_instance_methods :name, :meta, :stripped
    should have_instance_methods :rfc822, :rfc822=
    should have_instance_methods :internal_date, :internal_date=
    should have_instance_methods :message, :message=

    should "build a Mail Message from the raw IMAP attr data" do
      assert_kind_of ::Mail::Message, subject.message
    end

    should "provide the IMAP rfc822 and internal_date" do
      assert_equal TEST_MAIL_DATA['RFC822'], subject.rfc822
      assert_equal TEST_MAIL_DATA['INTERNALDATE'], subject.internal_date
    end

    should "be named by its uid, from, subject, and date" do
      exp = "[12345] suetest@kellyredding.com: \"test mail\" (Thu May 24 2012, 10:34 AM)"
      assert_equal exp, subject.name
    end

  end

  class StrippedMailItemTests < MailItemTests
    desc 'that has been stripped'
    before do
      @stripped = @item.stripped
    end
    subject { @stripped }

    should "be single part plain text only" do
      assert_equal 1, subject.message.parts.size
    end

    should "have no attachments" do
      assert_equal 0, subject.message.attachments.size
    end

    should "prefix the body with a note saying that it is stripped down" do
      pref = /\A\*\*\[inbox-sync\] stripped down to just plain text part\*\*/
      assert_match pref, subject.message.parts.first.body.to_s
    end

    should "set its RFC822 to the stripped message string" do
      assert_equal subject.rfc822, subject.message.to_s
    end
  end

end
