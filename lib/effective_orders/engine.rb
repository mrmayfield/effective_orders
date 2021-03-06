module EffectiveOrders
  class Engine < ::Rails::Engine
    engine_name 'effective_orders'

    config.autoload_paths += Dir["#{config.root}/app/models/**/"]

    # Include Helpers to base application
    initializer 'effective_orders.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper EffectiveOrdersHelper
        helper EffectiveCartsHelper
        helper EffectivePaypalHelper if EffectiveOrders.paypal_enabled
        helper EffectiveStripeHelper if EffectiveOrders.stripe_enabled
      end
    end

    # Include acts_as_addressable concern and allow any ActiveRecord object to call it
    initializer 'effective_orders.active_record' do |app|
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.extend(ActsAsPurchasable::ActiveRecord)
      end
    end

    initializer 'effective_orders.action_view' do |app|
      ActiveSupport.on_load :action_view do
        ActionView::Helpers::FormBuilder.send(:include, Inputs::PriceFormInput)
      end
    end

    # Set up our default configuration options.
    initializer "effective_orders.defaults", :before => :load_config_initializers do |app|
      eval File.read("#{config.root}/lib/generators/templates/effective_orders.rb")
    end

    # Set up our Stripe API Key
    initializer "effective_orders.stripe_api_key", :after => :load_config_initializers do |app|
      if EffectiveOrders.stripe_enabled
        require 'stripe'
        ::Stripe.api_key = EffectiveOrders.stripe[:secret_key]
      end
    end

    # ActiveAdmin (optional)
    # This prepends the load path so someone can override the assets.rb if they want.
    initializer 'effective_orders.active_admin' do
      if defined?(ActiveAdmin) && EffectiveOrders.use_active_admin == true
        ActiveAdmin.application.load_paths.unshift Dir["#{config.root}/active_admin"]
      end
    end

  end
end
