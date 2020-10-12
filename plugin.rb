# frozen_string_literal: true

# name: ClothingDeals
# about: Enter your clothing sizes in your profile and get pinged when someone post a deal in your size!
# version: 0.2
# authors: Maël Lavault
# url: https://github.com/Borasification/clothing-deals

register_asset 'stylesheets/common/clothing-deals.scss'
register_asset 'stylesheets/desktop/clothing-deals.scss', :desktop
register_asset 'stylesheets/mobile/clothing-deals.scss', :mobile

enabled_site_setting :clothing_deals_enabled

PLUGIN_NAME ||= 'ClothingDeal'

after_initialize do
  User.register_custom_field_type 'size_top', :string
  User.register_custom_field_type 'size_shirt', :string
  User.register_custom_field_type 'size_bottom', :string
  User.register_custom_field_type 'size_shoes', :string
  User.register_custom_field_type 'size_gloves', :string
  User.register_custom_field_type 'size_hat', :string
  User.register_custom_field_type 'receive_good_deals', :boolean

  register_editable_user_custom_field [:receive_good_deals, size_top: [], size_shirt: [], size_bottom: [], size_shoes: [], size_gloves: [], size_hat: []]

  DiscoursePluginRegistry.serialized_current_user_fields << 'size_top'
  DiscoursePluginRegistry.serialized_current_user_fields << 'size_shirt'
  DiscoursePluginRegistry.serialized_current_user_fields << 'size_bottom'
  DiscoursePluginRegistry.serialized_current_user_fields << 'size_shoes'
  DiscoursePluginRegistry.serialized_current_user_fields << 'size_gloves'
  DiscoursePluginRegistry.serialized_current_user_fields << 'size_hat'
  DiscoursePluginRegistry.serialized_current_user_fields << 'receive_good_deals'

  def user_ids_by_category_and_size(category, size)
    # Seems like we can't do a where by custom_fields in the ORM, so we have to execute SQL manually...
    begin
      result = ActiveRecord::Base.connection.execute("SELECT user_id FROM user_custom_fields WHERE name='#{category}' and value='#{size}'")
    rescue Exception => exc
      return []
    end
    return result.values.flatten
  end

  def on_post_created(post)
    categories_to_fields = {
      "veste" => "size_top",
      "chemise" => "size_shirt",
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

    user_ids_to_ping = []

    begin
      matches = post_contents.downcase.scan(/(@#{bot_username.downcase}) ([\S]+) ([\S]+)/)
      matches.each do |match|
        command, category, size = match
        if categories_to_fields.key?(category) && size
          user_ids_for_category_and_size = user_ids_by_category_and_size(categories_to_fields[category], size)
          user_ids_for_category_and_size.each do |user_id_for_category_and_size|
            if User.find(user_id_for_category_and_size).custom_fields["receive_good_deals"]
              user_ids_to_ping.push(user_id_for_category_and_size)
            end
          end
        end
      end
      grouped_user_id_notifications_count = user_ids_to_ping.group_by{ |id| id.to_s }.transform_values{ |values| values.count }
      grouped_user_id_notifications_count.each do |user_id, count|
        Notification.create!(
          notification_type: Notification.types[:custom],
          user_id: user_id,
          topic_id: topic.id,
          post_number: post.post_number,
          data: {topic_title: topic.title, icon: "mentioned", message: "js.clothing_deals.deal_notification_message", count: count}.to_json
        )
      end
    rescue => exception
      return
    end
  end

  def on_post_edited(original_post, modified_post)
    categories_to_fields = {
      "veste" => "size_top",
      "chemise" => "size_shirt",
      "pantalon" => "size_bottom",
      "chaussures" => "size_shoes",
      "gants" => "size_gloves",
      "chapeau" => "size_hat"
    }
    # original_post_contents = original_post.cached_original_raw.to_s
    original_post_contents = original_post.original_raw.to_s
    modified_post_contents = modified_post.raw.to_s

    bot_username = SiteSetting.deal_bot_user
    user_ids_to_ping = []

    # remove the 'quote' blocks
    original_post_contents.gsub!(%r{\[quote.*?\][^\[]+\[/quote\]}, '')
    modified_post_contents.gsub!(%r{\[quote.*?\][^\[]+\[/quote\]}, '')
    # begin
      original_matches = original_post_contents.downcase.scan(/(@#{bot_username.downcase}) ([\S]+) ([\S]+)/)
      modified_matches = modified_post_contents.downcase.scan(/(@#{bot_username.downcase}) ([\S]+) ([\S]+)/)

      puts "original: " + original_matches.to_json, "modified: " + modified_matches.to_json

      matches_diff = modified_matches.difference(original_matches)

      puts "diff: " + matches_diff.to_json

      # Return when we have the same commands as the original post or we don't have any commands in the edit
      if !matches_diff.any? || modified_matches.empty?
        return
      end


      modified_matches.each do |match|
        command, category, size = match
        if categories_to_fields.key?(category) && size
          user_ids_for_category_and_size = user_ids_by_category_and_size(categories_to_fields[category], size)
          user_ids_for_category_and_size.each do |user_id_for_category_and_size|
            if User.find(user_id_for_category_and_size).custom_fields["receive_good_deals"]
              user_ids_to_ping.push(user_id_for_category_and_size)
            end
          end
        end
      end
      grouped_user_id_notifications_count = user_ids_to_ping.group_by{ |id| id.to_s }.transform_values{ |values| values.count }
      grouped_user_id_notifications_count.each do |user_id, count|
        Notification.create!(
          notification_type: Notification.types[:custom],
          user_id: user_id,
          topic_id: original_post.topic_changes.topic["id"],
          post_number: modified_post_contents.post_number,
          data: {topic_title: original_post.topic_changes.topic["title"], icon: "mentioned", message: "js.clothing_deals.deal_notification_message", count: count}.to_json
        )
      end
    # rescue => exception
    #   return
    # end
  end

  DiscourseEvent.on(:post_created) do |post|
    on_post_created(post)
  end

  DiscourseEvent.on(:post_edited) do |*params|
    post, opts, post_revisor = params
    puts "Revisor" + post_revisor.inspect
    puts post.raw, post_revisor.cached_original_raw
    # If it's not been edited during the grace period
    if post_revisor.post_revision
      puts "Revision" + post_revisor.post_revision.inspect
      puts "Modifications" + post_revisor.post_revision.modifications.inspect
      on_post_edited(post_revisor.post_revision.modifications["raw"][0], post_revisor.post_revision.modifications["raw"][1])
    else
      on_post_edited(post_revisor, post)
    end
  end
end
