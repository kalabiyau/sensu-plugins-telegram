## Sensu-Plugins-telegram

<!-- [ ![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-campfire.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-campfire)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-campfire.svg)](http://badge.fury.io/rb/sensu-plugins-campfire)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-campfire/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-campfire)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-campfire/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-campfire)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-campfire.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-campfire) -->

## Functionality

This plugin provides a handler to send notifications to a Telegram chat.

## Files
 * bin/handler-telegram.rb

## Usage

After installation, you have to set up a `pipe` type handler, like so:

```json
{
  "handlers": {
    "telegram": {
      "type": "pipe",
      "command": "handler-telegram.rb"
    }
  }
}
```

This gem also expects a JSON configuration file with the following contents:

```json
{
  "telegram": {
    "bot_token": "YOUR_BOT_TOKEN",
    "chat_id": -123123,
    "error_file_location": "/tmp/telegram_handler_error"
  }
}
```

### Parameters:
- `bot_token`: your bot's token, as provided by
   [@BotFather](https://telegram.me/botfather).
- `chat_id`: the chat to which the error message is to be sent.
  The bot must be a member of this channel or group.
  You can get this chat_id by adding the bot to the corresponding group
  and then accessing `https://api.telegram.org/bot<TOKEN>/getUpdates`.
- `error_file_location` (optional): in case there is a failure sending the
  message to Telegram (ie. connectivity issues), the exception mesage will
  be written to a file in this location. You can then monitor this
  location to detect any errors with the Telegram handler.
- `message_template` (optional): An ERB template to use to format messages
  instead of the default. Supports the following variables:
  - `action_name`
  - `action_icon`
  - `client_name`
  - `check_name`
  - `status`
  - `status_icon`
  - `output`
- `message_template_file` (optional): A file to read an ERB template from to
  format messages. Supports the same variables as `message_template`.


### Advanced configuration

By default, the handler assumes that the config parameters are specified in the
`telegram` top-level key of the JSON, as shown above. You also have the option
to make the handler fetch the config from a different key. To do this, pass the
`-j` option to the handler with the name of the desired key You can define
multiple handlers, and each handler can send notifications to a different chat
and from a different bot. You could, for example, have critical and non-critical
Telegram groups, and send the notifications to one or the other depending on the
check. For example:

```json
{
  "handlers": {
    "critical_telegram": {
      "type": "pipe",
      "command": "handler-telegram.rb -j critical_telegram_options"
    },
    "non_critical_telegram": {
      "type": "pipe",
      "command": "handler-telegram.rb -j non_critical_telegram_options"
    }
  }
}
```

This example will fetch the options from a JSON like this:

```json
{
  "telegram": {
    "bot_token": "YOUR_BOT_TOKEN"
  },
  "critical_telegram_options": {
    "chat_id": -123123
  },
  "non_critical_telegram_options": {
    "chat_id": -456456
  }
}
```

As you can see, you can specify the default config in the `telegram` key, and
the rest of the config in their own custom keys.

You can also directly add the configuration parameters to the event data using a
mutator. For example:

```ruby
#!/usr/bin/env ruby
require 'rubygems'
require 'json'
event = JSON.parse(STDIN.read, :symbolize_names => true)
event.merge!(chat_id: -456456)
puts JSON.dump(event)
```

### Configuration precedence

The handler will load the config as follows (from least to most priority):

* Default `telegram` key
* Custom config keys
* Event data

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

## Notes
