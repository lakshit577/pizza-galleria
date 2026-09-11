# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


require "json"

orders_file = Rails.root.join("data", "orders.json")
orders = JSON.parse(File.read(orders_file))

orders.each do |order_data|
  created_at = Time.zone.parse(order_data.fetch("createdAt"))

  Order.find_or_initialize_by(id: order_data.fetch("id")).tap do |order|
    order.state = order_data.fetch("state")
    order.items = order_data.fetch("items")
    order.promotion_codes = order_data.fetch("promotionCodes", [])
    order.discount_code = order_data["discountCode"]
    order.created_at = created_at
    order.updated_at = created_at
    order.save!
  end
end

puts "Seeded #{orders.size} orders."