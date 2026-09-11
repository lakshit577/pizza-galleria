require "test_helper"

class OrderPriceCalculatorTest < ActiveSupport::TestCase
  test "calculates price for a simple order" do
    order = create_order(
      items: [
        {
          "name" => "Tonno",
          "size" => "Large",
          "add" => [],
          "remove" => []
        }
      ]
    )

    assert_equal BigDecimal("10.40"), OrderPriceCalculator.new(order).call
  end

  test "calculates price with extra ingredients and different sizes" do
    order = create_order(
      items: [
        {
          "name" => "Margherita",
          "size" => "Large",
          "add" => ["Onions", "Cheese", "Olives"],
          "remove" => []
        },
        {
          "name" => "Tonno",
          "size" => "Medium",
          "add" => [],
          "remove" => ["Onions", "Olives"]
        },
        {
          "name" => "Margherita",
          "size" => "Small",
          "add" => [],
          "remove" => []
        }
      ]
    )

    assert_equal BigDecimal("25.15"), OrderPriceCalculator.new(order).call
  end

  test "applies promotion and discount" do
    order = create_order(
      items: [
        {
          "name" => "Salami",
          "size" => "Medium",
          "add" => ["Onions"],
          "remove" => ["Cheese"]
        },
        {
          "name" => "Salami",
          "size" => "Small",
          "add" => [],
          "remove" => []
        },
        {
          "name" => "Salami",
          "size" => "Small",
          "add" => [],
          "remove" => []
        },
        {
          "name" => "Salami",
          "size" => "Small",
          "add" => [],
          "remove" => []
        },
        {
          "name" => "Salami",
          "size" => "Small",
          "add" => ["Olives"],
          "remove" => []
        }
      ],
      promotion_codes: ["2FOR1"],
      discount_code: "SAVE5"
    )

    assert_equal BigDecimal("16.29"), OrderPriceCalculator.new(order).call
  end

  private

  def create_order(items:, promotion_codes: [], discount_code: nil)
    Order.create!(
      state: "OPEN",
      items: items,
      promotion_codes: promotion_codes,
      discount_code: discount_code
    )
  end
end