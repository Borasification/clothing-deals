module ClothingDeal
  class ClothingDealController < ::ApplicationController
    requires_plugin ClothingDeal

    before_action :ensure_logged_in

    def index
    end
  end
end
