# frozen_string_literal: true

class AddressPoolsController < ApplicationController
  before_action :get_exercise, :get_network
  before_action :get_address_pool, only: %i[update destroy]

  respond_to :turbo_stream

  def create
    authorize @network, :update?
    @address_pool = @network.address_pools.create(name: "New addresspool #{@network.address_pools.size+1}")
  end

  def update
    form = AddressPoolForm.new(@address_pool, params[:address_pool])
    form.save
  end

  def destroy
    @address_pool.destroy
  end

  private
    def get_network
      @network = policy_scope(@exercise.networks)
        .friendly.find(params[:network_id])
    end

    def get_address_pool
      @address_pool = authorize(@network.address_pools.friendly.find(params[:id]))
    end
end
