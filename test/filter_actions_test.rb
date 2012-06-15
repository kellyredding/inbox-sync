require 'assert'
require 'inbox-sync/filter_actions'

module InboxSync

  class FilterActionsTests < Assert::Context
    before do
      @message = test_mail_item.message
      @filter_actions = InboxSync::FilterActions.new(@message)
    end
    subject { @filter_actions }

    should have_reader :message
    should have_instance_methods :copies, :flags

    should have_instance_methods :copy_to, :label
    should have_instance_methods :move_to, :archive_to
    should have_instance_methods :flag, :mark_read, :delete

    should have_instance_methods :match!, :apply!

    should "have no marks or copies and not be deleted by default" do
      assert_empty subject.copies
      assert_empty subject.flags
    end

    should "handle copy actions" do
      subject.copy_to 'somewhere'
      subject.label 'something'

      assert_equal ['somewhere', 'something'], subject.copies
    end

    should "only show valid, uniq copies when reading" do
      subject.copy_to 'valid'
      subject.copy_to
      subject.copy_to nil

      assert_equal ['valid'], subject.copies
    end

    should "handle move actions as a copy and archive" do
      subject.move_to 'somewhere'

      assert_equal ['somewhere'], subject.copies
      assert_equal [:Deleted], subject.flags
    end

    should "handle marking as read" do
      subject.mark_read

      assert_equal [:Seen], subject.flags
    end

    should "handle delete actions" do
      subject.delete

      assert_equal [:Deleted], subject.flags
    end

    should "handle flag actions" do
      subject.flag :A
      subject.flag :B, [:C]

      assert_equal [:A, :B, :C], subject.flags
    end

  end

end
