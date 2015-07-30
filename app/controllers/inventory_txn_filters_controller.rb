class InventoryTxnFiltersController < ApplicationController
  power :inventory_txn_filters
  # has_scope :by_period, :using => [:started_at, :ended_at], :type => :hash

  def new
    build_inventory_txn_filters
  end

  def create
    build_inventory_txn_filters
    if @inventory_txn_filters.save
      redirect_to root_url
    else
      render "new"
    end
  end

  private

  def build_inventory_txn_filters
      @inventory_txn_filters = InventoryTxnFilter.new(inventory_txn_filters_params)
  end

  def inventory_txn_filters
      inventory_txn_filters = params[:inventory_txn_filters]
      inventory_txn_filters.permit(:from_date, :to_date, :business_entity_location) if inventory_txn_filters
  end
end
