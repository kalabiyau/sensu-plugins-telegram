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

This gem requires a JSON configuration file with the following contents:

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

If you want to send some events to one chat, and other events to another
chat, you can directly add the chat_id to the event data (the `@event` hash)
using a mutator. Then, create one handler specification for each channel,
specifying the corresponding mutator. For example:

```ruby
#!/usr/bin/env ruby
require 'rubygems'
require 'json'
event = JSON.parse(STDIN.read, :symbolize_names => true)
event.merge!(chat_id: -456456)
puts JSON.dump(event)
```

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

## Notes
