require 'dotenv/load'
require_relative "lib/bot_mr_alex.rb"

bot = BotMrAlex.new(ENV['TOKEN'])
bot.new_session
