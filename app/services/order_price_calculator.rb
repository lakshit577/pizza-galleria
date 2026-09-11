# frozen_string_literal: true

require "bigdecimal"

class OrderPriceCalculator
  def initialize(order)
    @order = order
    @config = YAML.load_file(Rails.root.join("data", "config.yml"))
  end

  def call
    total = calculate_items_total
    total = apply_promotions(total)
    total = apply_discount(total)

    total.round(2)
  end

  private

  attr_reader :order, :config

  def calculate_items_total
    order.items.sum do |item|
      pizza_price(item) + ingredients_price(item)
    end
  end

  def pizza_price(item)
    base_price(item["name"]) * size_multiplier(item["size"])
  end

  def ingredients_price(item)
    item.fetch("add", []).sum do |ingredient|
      ingredient_price(ingredient) * size_multiplier(item["size"])
    end
  end

  def apply_promotions(total)
    order.promotion_codes.each do |promotion_code|
      promotion = config.fetch("promotions").fetch(promotion_code)

      matching_items = order.items.select do |item|
        item["name"] == promotion["target"] &&
          item["size"] == promotion["target_size"]
      end

      from = promotion["from"]
      to = promotion["to"]

      free_items = (matching_items.length / from) * (from - to)

      free_items.times do
        matching_item = matching_items.shift
        total -= pizza_price(matching_item)
      end
    end

    total
  end

  def apply_discount(total)
    return total if order.discount_code.blank?

    discount = config.fetch("discounts").fetch(order.discount_code)
    percentage = BigDecimal(discount["deduction_in_percent"].to_s)

    total - (total * percentage / 100)
  end

  def base_price(pizza)
    BigDecimal(config.fetch("pizzas").fetch(pizza).to_s)
  end

  def ingredient_price(ingredient)
    BigDecimal(config.fetch("ingredients").fetch(ingredient).to_s)
  end

  def size_multiplier(size)
    BigDecimal(config.fetch("size_multipliers").fetch(size).to_s)
  end
end