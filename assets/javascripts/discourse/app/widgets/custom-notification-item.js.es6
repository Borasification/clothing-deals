import I18n from "I18n";
import { createWidgetFrom } from "discourse/widgets/widget";
import { DefaultNotificationItem } from "discourse/widgets/default-notification-item";
import { formatUsername } from "discourse/lib/utilities";
import { iconNode } from "discourse-common/lib/icon-library";

createWidgetFrom(DefaultNotificationItem, "custom-notification-item", {
  notificationTitle(notificationName, data) {
    return data.title ? I18n.t(data.title) : "";
  },

  text(notificationName, data) {
    const count = data.count;

    return I18n.t(data.message, { count });
  },

  icon(notificationName, data) {
    return iconNode(`notification.${data.icon}`);
  },
});
