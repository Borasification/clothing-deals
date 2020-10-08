# frozen_string_literal: true

# name: ClothingDeals
# about: Enter your clothing sizes in your profile and get pinged when someone post a deal in your size!
# version: 0.1
# authors: Maël Lavault
# url: https://github.com/moimael

register_asset 'stylesheets/common/clothing-deals.scss'
register_asset 'stylesheets/desktop/clothing-deals.scss', :desktop
register_asset 'stylesheets/mobile/clothing-deals.scss', :mobile
require 'current_user'

enabled_site_setting :clothing_deals_enabled

PLUGIN_NAME ||= 'ClothingDeal'

load File.expand_path('lib/clothing-deals/engine.rb', __dir__)

after_initialize do
  User.register_custom_field_type 'size_top', :string
  User.register_custom_field_type 'size_bottom', :string
  User.register_custom_field_type 'size_shoes', :string
  User.register_custom_field_type 'size_gloves', :string
  User.register_custom_field_type 'size_hat', :string
  User.register_custom_field_type 'receive_good_deals', :boolean

  register_editable_user_custom_field [:size_top, :size_bottom, :size_shoes, :size_gloves, :size_hat, :receive_good_deals]

  DiscoursePluginRegistry.serialized_current_user_fields << 'size_top'
  DiscoursePluginRegistry.serialized_current_user_fields << 'size_bottom'
  DiscoursePluginRegistry.serialized_current_user_fields << 'size_shoes'
  DiscoursePluginRegistry.serialized_current_user_fields << 'size_gloves'
  DiscoursePluginRegistry.serialized_current_user_fields << 'size_hat'
  DiscoursePluginRegistry.serialized_current_user_fields << 'receive_good_deals'

  def on_post_created(post)
    categories_to_fields = {
      "veste" => "size_top",
      "pantalon" => "size_bottom",
      "chaussures" => "size_shoes",
      "gants" => "size_gloves",
      "chapeau" => "size_hat"
    }

    user = post.user
    topic = post.topic

    post_contents = post.raw.to_s

    # remove the 'quote' blocks
    post_contents.gsub!(%r{\[quote.*?\][^\[]+\[/quote\]}, '')

    bot_username = SiteSetting.deal_bot_user

    mentions_bot_name = post_contents.downcase =~ /@#{bot_username.downcase}\b/
    command, category, size = post_contents.match(/(@#{bot_username.downcase}) ([\S]+) ([\S]+)/).captures

    if mentions_bot_name && categories_to_fields.key?(category) && size
      # Seems like we can't do a where by custom_fields in the ORM, so we have to execute SQL manually...
      begin
        result = ActiveRecord::Base.connection.execute("SELECT user_id FROM user_custom_fields WHERE name='#{categories_to_fields[category]}' and value='#{size}'")
        resultUsersNotificationsEnabled = ActiveRecord::Base.connection.execute("SELECT user_id FROM user_custom_fields WHERE name='receive_good_deals' and value='#{true}'")
      rescue Exception => exc
        puts exc
        return
      end
      user_ids_notification_enabled = resultUsersNotificationsEnabled.values.flatten
      user_ids_with_corresponding_size = result.values.flatten
      user_ids_to_ping = user_ids_with_corresponding_size.intersection(user_ids_notification_enabled)
      puts user_ids_to_ping

      user_ids_to_ping.each do |user_id_to_ping|
        Notification.create!(
          notification_type: Notification.types[:custom],
          user_id: user_id_to_ping,
          topic_id: topic.id,
          post_number: post.id,
          data: {message: "js.clothing_deals.deal_notification_message"}.to_json
        )
      end
    end
  end

  DiscourseEvent.on(:post_created) do |*params|
    post, opts, user = params
    on_post_created(post)
  end
end
