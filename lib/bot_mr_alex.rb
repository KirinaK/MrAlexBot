require 'telegram/bot'
require 'net/http/post/multipart'
require_relative '../constants.rb'
require 'pry'
require 'dotenv/load'

class BotMrAlex
  class << self
    def new_session
      Telegram::Bot::Client.run(ENV['TOKEN']) do |bot|
        bot.listen do |message|
          case message.text  
          when '/start'
            send_message(bot.api, message.chat.id, "Hello, #{message.from.first_name}.")
            send_message(bot.api, message.chat.id, TEXT_MESSAGES['start'])
          when '/go'
            send_message(bot.api, message.chat.id, TEXT_MESSAGES['go'])
          when '/stop'
            send_message(bot.api, message.chat.id, "Bye, #{message.from.first_name}")
          when '/help'
            send_message(bot.api, message.chat.id, TEXT_MESSAGES['help'])
          when '/yes'
            send_message(bot.api, message.chat.id, TEXT_MESSAGES['yes'])
          when '/no'
            send_message(bot.api, message.chat.id, TEXT_MESSAGES['no'])
          else
            check_current_mood(bot.api, message)
          end
        end
      end
    end

    private

    def send_message(bot_api, chat_id, msg)
      bot_api.sendMessage(chat_id: chat_id, text: msg)
    end

    def send_photo(bot_api, chat_id, photo)
      bot_api.sendPhoto(chat_id: chat_id, photo: photo)
    end

    def content_validation(msg)
      !msg.photo.empty? || !msg.audio.nil? || !msg.sticker.nil? || !msg.video.nil? || !msg.voice.nil?
    end

    def check_current_mood(bot_api, msg)
      if content_validation(msg)
        send_message(bot_api, msg.chat.id, TEXT_MESSAGES['else_content'])
        send_photo(bot_api, msg.chat.id, Faraday::UploadIO.new("images/cat_content.jpg", "jpg"))
        send_message(bot_api, msg.chat.id, TEXT_MESSAGES['repeat'])
      else
        if (1..10).include?(msg.text.to_i)
          send_message(bot_api, msg.chat.id, TEXT_MESSAGES[msg.text])
          send_photo(bot_api, msg.chat.id, Faraday::UploadIO.new("images/cat_#{msg.text}.jpg", "jpg"))
          send_message(bot_api, msg.chat.id, TEXT_MESSAGES['repeat'])
        elsif msg.text =~ /^\//
          send_message(bot_api, msg.chat.id, TEXT_MESSAGES['else_command'] + "\n" + TEXT_MESSAGES['help']) 
        else
          send_message(bot_api, msg.chat.id, TEXT_MESSAGES['else_num'])
          send_photo(bot_api, msg.chat.id, Faraday::UploadIO.new("images/cat_error.jpg", "jpg"))
          send_message(bot_api, msg.chat.id, TEXT_MESSAGES['repeat'])
        end
      end
    end
  end
end
