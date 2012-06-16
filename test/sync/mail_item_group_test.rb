require 'assert'

require 'inbox-sync/sync/mail_item_group'

module InboxSync

  class SyncMailItemGroupTests < Assert::Context
    desc "a runner mail item group"
    before do
      @group = Sync::MailItemGroup.new('dummy sync')
    end
    subject { @group }

    should have_readers :thread, :items
    should have_instance_methods :id, :add, :run, :join

  end

end
