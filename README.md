# InboxSync

Move messages from one inbox to another.  Useful when server-side email forwarding is not an option.  Can apply rules to messages as they are being moved.  Run on-demand, on a schedule, or as a daemon.

## Installation

Add this line to your application's Gemfile:

    gem 'inbox-sync'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install inbox-sync

## Usage

It should be fairly straight-forward: create and configure a sync then run it.  This will move all messages in the `source` inbox to the `dest` inbox.

### Create your Sync

```ruby
sync = InboxSync.new
```

### Configure it

```ruby
# manually set configs
sync.config.source.host = 'imap.source-host.com'

# or use a more DSL like approach
sync.config.source.login.user 'me'
sync.config.source.login.pw   'secret'

# use a configure block, if you like
sync.configure do
  dest.host  'imap.dest-host.com'
  dest.login 'me', 'secret'
end
```

### Run it

```ruby
InboxSync.run(sync)
```

InboxSync uses IMAP to query the source inbox, process its messages, append them to the dest inbox, and archive them on the source.

## Configs

### `source`

IMAP settings for the source inbox.

* *host*: eg. `'imap.some-domain.com'`.
* *port*: defaults to `143`.
* *ssl*:  whether to use SSL.  defaults to `false`.
* *login*: credentials (user, pw).
* *inbox*: name of the inbox folder.  defaults to `'INBOX'`
* *expunge*: whether to expunge the inbox before and after processing.  defaults to `true`.

### `dest`

IMAP settings for the destination inbox.  Has the some attributes and defaults as the `source`.

### `notify`

SMTP settings to send notifications with.

* *host*: eg. `'smtp.some-domain.com'`.
* *port*: defaults to `587`.
* *tls*: whethe to use TLS encryption.  defaults to `true`.
* *helo*: the helo domain to send with.
* *login*: credentials (user, pw).
* *authtype*: defaults to `:login`.
* *to_addrs*: address(es) to send the notifications to.

### `archive_folder`

The folder on the source to create and archive (move) source inbox messages to when processing is complete.  Defaults to `"Forwarded"`.

## Rules

TODO

## Notifications

TODO

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
