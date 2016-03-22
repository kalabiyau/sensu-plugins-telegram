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
#   For more details, please see the README.
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
require 'cgi'

class TelegramHandler < Sensu::Handler
  def chat_id
    @event['chat_id'] || settings['telegram']['chat_id']
  end

  def bot_token
    @event['bot_token'] || settings['telegram']['bot_token']
  end

  def error_file
    @event['error_file_location'] || settings['telegram']['error_file_location']
  end

  def event_name
    client_name + '/' + check_name
  end

  def action_name
    actions = {
      'create' => 'Created',
      'resolve' => 'Resolved',
      'flapping' => 'Flapping'
    }
    actions[@event['action']]
  end

  def action_icon
    icons = {
      'create' => "\xF0\x9F\x98\xB1",
      'resolve' => "\xF0\x9F\x98\x8D",
      'flapping' => "\xF0\x9F\x90\x9D"
    }
    icons[@event['action']]
  end

  def client_name
    escape_html @event['client']['name']
  end

  def check_name
    escape_html @event['check']['name']
  end

  def output
    escape_html @event['check']['output']
  end

  def escape_html(string)
    CGI.escapeHTML(string)
  end

  def telegram_url
    "https://api.telegram.org/bot#{bot_token}/sendMessage"
  end

  def build_message
    [
      "<b>Alert #{action_name}</b> #{action_icon}",
      "<b>Host:</b> #{client_name}",
      "<b>Check:</b> #{check_name}",
      "<b>Status:</b> #{translate_status} #{status_icon}",
      "<b>Output:</b> <code>#{output}</code>"
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
      f.puts 'URL: ' + telegram_url
      f.puts 'Params: ' + params.inspect
      f.puts 'Exception: ' + exception.inspect
    end if error_file
  end

  def clear_error
    File.delete(error_file) if error_file && File.exist?(error_file)
  end

  def handle
    print 'Sending to Telegram: ' + params.inspect
    RestClient.post(telegram_url, params, format: :json)
    puts '... done.'
    clear_error
  rescue SocketError, RestClient::Exception => e
    handle_error(e)
    puts "... Telegram handler error '#{e.inspect}' while attempting to report an incident: #{event_name} #{action_name}"
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

  def status_icon
    icons = {
      0 => "\xF0\x9F\x91\x8D",
      1 => "\xE2\x9A\xA1",
      2 => "\xF0\x9F\x9A\xA8",
      3 => "\xF0\x9F\x8C\x80"
    }
    icons[check_status.to_i]
  end
end
