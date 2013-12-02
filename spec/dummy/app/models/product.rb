class Product < ActiveRecord::Base
  acts_as_purchasable

  structure do
    price               :decimal, :precision => 8, :scale => 2, :default => 0.00
    title               :string
    tax_exempt          :boolean

    timestamps
  end

end
