require 'assert'

require 'inbox-sync/sync'
require 'inbox-sync/runner'

module InboxSync

  class RunnerTests < Assert::Context
    desc "a sync runner"
    before do
      @syncs = [InboxSync::Sync.new, InboxSync::Sync.new]
      @runner = InboxSync::Runner.new(@syncs, :interval => 20)
    end
    subject { @runner }

    should have_readers :syncs, :interval, :logger

    should "know its syncs" do
      assert_equal @syncs, subject.syncs
    end

    should "know its interval seconds" do
      assert_equal 20, subject.interval
    end

    should "default its interval to -1" do
      assert_equal -1, InboxSync::Runner.new.interval
    end

    should "build from zero or many syncs" do
      assert_equal @syncs, InboxSync::Runner.new(@syncs).syncs
      assert_equal @syncs, InboxSync::Runner.new(*@syncs).syncs
      assert_equal [@syncs.first], InboxSync::Runner.new(@syncs.first).syncs
      assert_equal [], InboxSync::Runner.new(:interval => 5).syncs
      assert_equal [], InboxSync::Runner.new().syncs
    end

  end

end
