# InboxSync

Move messages from one inbox to another.  Useful when server-side email forwarding is not an option.  (TODO) Can apply filters to messages as they are being moved.  Run on-demand, on a schedule, or as a daemon.

## Installation

Add this line to your application's Gemfile:

    gem 'inbox-sync'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install inbox-sync

# How does it work?

InboxSync uses IMAP to query a source inbox, process its messages, append them to a destination inbox, and archive them on the source.  It logs each step in the process and will send notification emails when something goes wrong.

(TODO) InboxSync provides a framework for defining destination filters for post-sync mail processing (ie moving/archiving, copying/labeling, deletion, etc).

InboxSync provides a basic ruby runner class to handle polling the source on an interval and running the configured sync(s).  You can call it in any number of ways: in a script, from a cron, as a daemon, or as part of a larger system.

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

# or use a configure block, if you like
sync.configure do
  dest.host  'imap.dest-host.com'
  dest.login 'me', 'secret'
end
```

### Run it

```ruby
InboxSync.run(sync, :interval => 5)
```

## Sync Definition

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
* *port*: defaults to `25`.
* *tls*: whethe to use TLS encryption.  defaults to `false`.
* *helo*: the helo domain to send with.
* *login*: credentials (user, pw).
* *authtype*: defaults to `:login`.
* *from_addr*: address to send the notifications from.
* *to_addr*: address(es) to send the notifications to.

### `archive_folder`

The (optional) folder on the source to create and archive (move) source inbox messages to when processing is complete.  Defaults to `"Archived"`.  Set to `nil` to disable archiving on the source and delete the messages after processing.

### `logger`

A logger to use.  Defaults to ruby's `Logger` on `STDOUT`.

## Running

InboxSync provides a `Runner` class that will loop indefinitely, running syncs every `:interval` seconds.  Stick it in a daemon, a rake task, a CLI, or whatever depending on how you want to invoke it.  Here is an example using it in a basic ruby script:

```ruby
require 'inbox-sync'

sync = InboxSync.new.configure do
  source.host  'imap.gmail.com'
  source.port  993
  source.ssl   'Yes'
  source.login 'joetest@kellyredding.com', 'joetest1'

  dest.host  'imap.gmail.com'
  dest.port  993
  dest.ssl   'Yes'
  dest.login 'suetest@kellyredding.com', 'suetest1'

  notify.host    'smtp.gmail.com'
  notify.port    587
  notify.tls     'Yes'
  notify.helo    'gmail.com'
  notify.login   'joetest@kellyredding.com', 'joetest1'
  notify.to_addr 'joetest@kellyredding.com'
  notify.to_addr 'suetest@kellyredding.com'

  logger Logger.new('log/inbox-sync.log')
end

InboxSync.run(sync, :interval => 20)
```

The `InboxSync.run` method is just a macro for creating a runner and calling its `start` method.

```ruby
InboxSync::Runner.new(sync, :interval => 5).start
```

By default, it will log to `STDOUT` but accepts a `:logger` option to override this.

```ruby
InboxSync.run(sync, {
  :interval => 5,
  :logger => Logger.new('/path/to/log.log')
})
```

You can pass any number of syncs to run.  Each `:interval` period, it will run them sequentially:

```ruby
InboxSync.run(sync1, sync2, sync3, :interval => 5)
```

If you pass no `:interval` option (or pass a negative value for it), the runner will run the sync(s) once and then exit instead of running the syncs indefinitely on the interval.

```ruby
InboxSync.run(sync)
```

The runner traps `SIGINT` and `SIGQUIT` and will shutdown nicely once any in-progress syncs have finished.

## Filter Framework

TODO

## Error Handling

InboxSync generates detailed logs of both running its syncs and processing sync mail items.  If a mail fails to append (ie rejected by the dest IMAP), InboxSync will attempt to strip the mail to its most basic (ie plain/text) form and will retry the append.

In addtion, InboxSync will notify via email when something goes wrong with a sync.  You configure `notify` settings when defining your syncs.  These settings determine where/how notifications are sent out.  There are two types a notifications InboxSync will send: `RunSyncError` and `SyncMailItemError`.

In any case, if an `archive_folder` is set, no source messages will be permanently deleted and are always available there for reference.

### `RunSyncError` notification

This notification is sent when there is a problem running a sync in general.  For example, the sync can't connect to the source to read its mail items or the runner itself has a runtime exception.  This notification lets you know that something went wrong and that mail items aren't being sync'd.  It also details the exception that happened with a full backtrace.

### `SyncMailItemError` notification

This notification is sent wnen there is a problem syncing a specific mail item.  For example the destination rejects the append or there was a problem archiving the mail item at the source.  It lets you know there was a problem and gives you some info about the email that had a problem.  It also details the exception that happened with a full backtrace.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
