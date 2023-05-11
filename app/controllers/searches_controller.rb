# frozen_string_literal: true

class SearchesController < ApplicationController
  respond_to :turbo_stream

  def create
    if params[:query].present?
      @results = [
        policy_scope(VirtualMachine)
          .joins(:exercise)
          .merge(Exercise.active)
          .search(params[:query])
          .limit(5),
        policy_scope(Network)
          .joins(:exercise)
          .merge(Exercise.active)
          .search(params[:query])
          .limit(5),
        policy_scope(OperatingSystem)
          .search(params[:query])
          .limit(5),
      ].flatten
    else
      @results = []
    end
  end
end
