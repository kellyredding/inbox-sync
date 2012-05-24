# this file is automatically required in when you require 'assert' in your tests
# put test helpers here

# add root dir to the load path
$LOAD_PATH.unshift(File.expand_path("../..", __FILE__))


class Assert::Context

  def configured_sync
    InboxSync::Sync.new.configure do
      source.host  'imap.gmail.com'
      source.port  993
      source.ssl   'Yes'
      source.login 'joetest@kellyredding.com', 'joetest1'

      dest.host  'imap.gmail.com'
      dest.port  993
      dest.ssl   'Yes'
      dest.login 'suetest@kellyredding.com', 'suetest1'

      notify.host  'smtp.gmail.com'
      notify.port  587
      notify.tls   'Yes'
      notify.helo  'gmail.com'
      notify.login 'suetest@kellyredding.com', 'suetest1'
      notify.to_addrs 'suetest@kellyredding.com'
    end
  end

end
