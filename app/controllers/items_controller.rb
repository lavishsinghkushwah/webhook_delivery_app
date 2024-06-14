class ItemsController < ApplicationController
  protect_from_forgery with: :null_session # Disable CSRF protection for simplicity

  def create
    @item = Item.new(item_params)
    if @item.save
      notify_third_parties(@item)
      render json: @item, status: :created
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def update
    @item = Item.find(params[:id])
    if @item.update(item_params)
      notify_third_parties(@item)
      render json: @item, status: :ok
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :data)
  end

  def notify_third_parties(item)
    endpoints = Rails.application.config.third_party_endpoints
    endpoints.each do |endpoint|
      WebhookNotifier.notify(endpoint, item)
    end
  end
end
