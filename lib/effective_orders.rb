require 'effective_addresses'
require "effective_orders/engine"
require 'migrant'     # Required for rspec to run properly

module EffectiveOrders
  PURCHASED = 'purchased'
  DECLINED = 'declined'

  # The following are all valid config keys
  mattr_accessor :orders_table_name
  mattr_accessor :order_items_table_name
  mattr_accessor :carts_table_name
  mattr_accessor :cart_items_table_name
  mattr_accessor :customers_table_name
  mattr_accessor :subscriptions_table_name

  mattr_accessor :authorization_method
  mattr_accessor :tax_rate_method

  mattr_accessor :layout
  mattr_accessor :simple_form_options
  mattr_accessor :use_active_admin
  mattr_accessor :obfuscate_order_ids
  mattr_accessor :silence_deprecation_warnings

  mattr_accessor :allow_pretend_purchase_in_production
  mattr_accessor :allow_pretend_purchase_in_production_message

  mattr_accessor :require_billing_address
  mattr_accessor :require_shipping_address

  mattr_accessor :collect_user_fields
  mattr_accessor :skip_user_validation

  mattr_accessor :minimum_charge
  mattr_accessor :allow_free_orders

  mattr_accessor :paypal_enabled
  mattr_accessor :moneris_enabled

  # application fee  is required if stripe_connect_enabled is true
  mattr_accessor :stripe_enabled

  mattr_accessor :stripe_subscriptions_enabled
  mattr_accessor :stripe_connect_enabled
  mattr_accessor :stripe_connect_application_fee_method

  # These are hashes of configs
  mattr_accessor :mailer
  mattr_accessor :paypal
  mattr_accessor :moneris
  mattr_accessor :stripe

  def self.setup
    yield self
  end

  def self.authorized?(controller, action, resource)
    if authorization_method.respond_to?(:call) || authorization_method.kind_of?(Symbol)
      raise Effective::AccessDenied.new() unless (controller || self).instance_exec(controller, action, resource, &authorization_method)
    end
    true
  end

  def self.minimum_charge
    if @@minimum_charge.nil? || @@minimum_charge.kind_of?(Integer)
      @@minimum_charge
    else
      ActiveSupport::Deprecation.warn('EffectiveOrders.minimum_charge config option is a non-integer. It should be an Integer representing the number of cents.  Continuing with (price * 100.0).round(0).to_i conversion') unless EffectiveOrders.silence_deprecation_warnings
      ((@@minimum_charge * 100.0).round(0).to_i rescue nil)
    end
  end

  class SoldOutException < Exception; end
  class AlreadyPurchasedException < Exception; end
  class AlreadyDeclinedException < Exception; end

end
