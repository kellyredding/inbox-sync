# Inbox::Syncro

Move messages from one inbox to another.  Useful when server-side email forwarding is not an option.  Can apply rules to messages as they are being moved.  Run on-demand, on a schedule, or as a daemon.  Apply rules to messages as they are moved.

## Installation

Add this line to your application's Gemfile:

    gem 'inbox-syncro'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install inbox-syncro

## Usage

It should be fairly straight-forward: create and configure a syncro then run it.  This will move all messages in the `source` inbox to the `dest` inbox.

### Create your Syncro

```ruby
sync = InboxSyncro.new
```

### Configure it

```ruby
# manually set configs
sync.source.host = 'imap.source-host.com'

# or use a more DSL like approach
sync.source.login.user 'me'
sync.source.login.pw   'secret'

# use a configure block, if you like
sync.configure do
  dest.host  'imap.dest-host.com'
  dest.login 'me', 'secret'
end
```

### Run it

```ruby
InboxSyncro.run(sync)
```

InboxSyncro uses IMAP to query the source inbox, process its messages, append them to the dest inbox, and archive them on the source.

## Configs

TODO

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
