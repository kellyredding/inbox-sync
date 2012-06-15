require 'assert'
require 'inbox-sync/config/filter'

module InboxSync

  class ConfigFilterTests < Assert::Context
    before do
      @filter = InboxSync::Config::Filter.new({
        :subject => 'test',
        :from => /kellyredding.com\Z/
      })
    end
    subject { @filter }

    should have_reader :conditions, :actions
    should have_instance_method :match?

    should "convert condition values to regexs if not" do
      assert_kind_of Hash, subject.conditions
      subject.conditions.each do |k,v|
        assert_kind_of Regexp, v
      end
    end

    should "know if it matches a message" do
      assert subject.match?(test_mail_item.message)
    end

  end

end
