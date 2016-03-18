#!/usr/bin/env ruby
#
#   handler-telegram
#
# DESCRIPTION:
#   This handler sends messages to a given Telegram chat (person, group
#   or channel).
#
# OUTPUT:
#   Plain text
#
# PLATFORMS:
#   Linux, BSD, Windows, OS X
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: rest-client
#
# USAGE:
#   This gem requires a JSON configuration file with the following contents:
#     {
#       "telegram": {
#         "bot_token": "YOUR_BOT_TOKEN",
#         "chat_id": -123123,
#         "error_file_location": "/tmp/telegram_handler_error"
#       }
#     }
#
#   Parameters:
#     - bot_token: your bot's token, as provided by @BotFather
#     - chat_id: the chat to which the error message is to be sent.
#       The bot must be a member of this channel or group.
#       You can get this chat_id by adding the bot to the corresponding group
#       and then accessing https://api.telegram.org/bot<TOKEN>/getUpdates
#     - error_file_location (optional): in case there is a failure sending the
#       message to Telegram (ie. connectivity issues), the exception mesage will
#       be written to a file in this location. You can then monitor this
#       location to detect any errors with the Telegram handler.
#
#   If you want to send some events to one chat, and other events to another
#   chat, you can directly add the chat_id to the event data (the `@event` hash)
#   using a mutator. For example:
#     #!/usr/bin/env ruby
#     require 'rubygems'
#     require 'json'
#     event = JSON.parse(STDIN.read, :symbolize_names => true)
#     event.merge!(chat_id: -456456)
#     puts JSON.dump(event)
#
# NOTES:
#
# LICENSE:
#
#   Copyright 2016 Hernan Schmidt <hschmidt@suse.de>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'restclient'

class TelegramHandler < Sensu::Handler

  def chat_id
    @event['chat_id'] || settings['telegram']['chat_id']
  end

  def bot_token
    settings['telegram']['bot_token']
  end

  def error_file
    settings['telegram']['error_file_location']
  end

  def event_name
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def action_name
    actions = {
      'create' => 'Created',
      'resolve' => 'Resolved',
      'flapping' => 'Flapping'
    }
    actions[@event['action']]
  end

  def telegram_url
    "https://api.telegram.org/bot#{bot_token}/sendMessage"
  end

  def build_message
    [
      "<b>Alert #{action_name}</b>",
      "<b>Host:</b> #{@event['client']['name']}",
      "<b>Check:</b> #{@event['check']['name']}",
      "<b>Status:</b> #{translate_status}",
      "<b>Output:</b> #{@event['check']['output']}"
    ].join("\n")
  end

  def params
    {
      chat_id: chat_id,
      text: build_message,
      parse_mode: 'HTML',
      disable_web_page_preview: true
    }
  end

  def handle_error(exception)
    open(error_file, 'w') do |f|
      f.puts "URL: " + telegram_url
      f.puts "Params: " + params.inspect
      f.puts "Exception: " + exception.inspect
    end if error_file
  end

  def clear_error
    File.delete(error_file) if File.exist?(error_file)
  end

  def handle
    begin
      print "Sending to Telegram: " + params.inspect
      RestClient.post(telegram_url, params, format: :json)
      puts "... done."
      clear_error
    rescue SocketError, RestClient::Exception => e
      handle_error(e)
      puts "... Telegram handler error '#{e.inspect}' while attempting to report an incident: #{event_name} #{action_name}"
    end
  end

  def check_status
    @event['check']['status']
  end

  def translate_status
    status = {
      0 => 'OK',
      1 => 'Warning',
      2 => 'Critical',
      3 => 'Unknown'
    }
    status[check_status.to_i]
  end
end
