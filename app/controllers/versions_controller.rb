# frozen_string_literal: true

class VersionsController < ApplicationController
  def index
    @versions = policy_scope(Version)
      .order(created_at: :desc)
      .page(params[:page])
  end

  def show
    @version = policy_scope(Version).find(params[:id])
  end
end
