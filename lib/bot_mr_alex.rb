require 'telegram/bot'
require 'net/http/post/multipart'
require 'pry'
require 'yaml'

class BotMrAlex
  TEXT = YAML.load_file('constants.yml')

  def initialize(token)
    Telegram::Bot::Client.run(token) { |bot| @bot = bot }
    @api = @bot.api
  end

  def new_session
    @bot.listen do |message|
      @chat_id = message.chat.id

      hash = {
        '/start' => "Hello, #{message.from.first_name}." + "\n" + TEXT['start'],
        '/go' => TEXT['go'],
        '/stop' => "Bye, #{message.from.first_name}",
        '/help' => TEXT['help'],
        '/yes' => TEXT['active'],
        '/no' => TEXT['negative']
      }

      if message.text =~ /^\//
        text = hash[message.text] || (TEXT['else_command'] + "\n" + TEXT['help'])
        send_message(text)
      else
        check_current_mood(message)
      end
    end
  end

  private

  def send_message(msg)
    @api.sendMessage(chat_id: @chat_id, text: msg)
  end

  def send_photo(photo)
    @api.sendPhoto(chat_id: @chat_id, photo: photo)
  end

  def content_validation(msg)
    !msg.photo.empty? || !msg.audio.nil? || !msg.sticker.nil? || !msg.video.nil? || !msg.voice.nil?
  end

  def answer_from_bot(key_msg, img)
    send_message(TEXT[key_msg])
    send_photo(Faraday::UploadIO.new("images/cat_#{img}.jpg", "jpg"))
    send_message(TEXT['repeat'])
  end

  def check_current_mood(msg)
    return answer_from_bot('else_content', 'content') if content_validation(msg)

    if (1..10).include?(msg.text.to_i)
      answer_from_bot(msg.text.to_i, msg.text)
    else
      answer_from_bot('else_num', 'error')
    end
  end
end
