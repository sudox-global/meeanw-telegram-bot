class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include EncryptionHelper

  before_action :publish_message

  def publish_message
    secret_key = 'd139a992f89c6577'

    Publisher.publish(bot.username, {
      update_id: update["update_id"],
      bot_uri: EncryptionHelper.encrypt(bot.base_uri, secret_key),
      bot_token:  EncryptionHelper.encrypt(bot.token, secret_key),
      chat: chat,
      from: from,
      payload: payload,
      payload_type: payload_type,
      session: session,
      action_options: action_options,
      action_name: action_name,
      response_body: response_body
    })
  end
end
