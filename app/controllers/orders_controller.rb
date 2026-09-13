class OrdersController < ApplicationController
  def index
    @orders = Order.where(state: "OPEN").order(created_at: :asc)
  end

  def update
    order = Order.find(params[:id])
    order.update!(state: "COMPLETED")

    redirect_to orders_path
  end
end