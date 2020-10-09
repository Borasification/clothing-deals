import { withPluginApi } from "discourse/lib/plugin-api";

function initializeClothingDeal(api) {
  api.modifyClass("controller:preferences/profile", {
    actions: {
      save() {
        this.get("saveAttrNames").push("custom_fields");
        this._super();
      },
    },
  });
}

export default {
  name: "clothing-deals",
  initialize() {
    withPluginApi("0.8.31", initializeClothingDeal);
  },
};
