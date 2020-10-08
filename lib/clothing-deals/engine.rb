module ClothingDeal
  class Engine < ::Rails::Engine
    engine_name "ClothingDeal".freeze
    isolate_namespace ClothingDeal

    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::ClothingDeal::Engine, at: "/clothing-deals"
      end
    end
  end
end
