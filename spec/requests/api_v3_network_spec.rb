# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API v3 networks', type: :request do
  let(:exercise) { create(:exercise) }
  let!(:networks) { create_list(:network, 2, exercise:) }

  let!(:user) { create(:user, api_tokens: [api_token], permissions: Hash[exercise.id, ['local_admin']]) }
  let(:api_token) { create(:api_token) }
  let(:headers) { { 'Authorization' => "Token #{api_token.token}" } }

  before { get "/api/v3/#{exercise.slug}/networks", headers: }

  it 'lists all networks' do
    expect(response).to be_successful
    expect(response.parsed_body).to have_key('result')
    networks.each do |net|
      expect(response.parsed_body['result']).to include(
        {
          id: net.slug,
          name: net.name,
          description: nil,
          actor: net.actor.abbreviation.downcase,
          instances: [{
            team_nr: nil,
            cloud_id: '',
            domains: [],
            address_pools: [
              { id: 'default-ipv4', ip_family: 'v4', network_address: '', gateway: nil },
              { id: 'default-ipv6', ip_family: 'v6', network_address: '', gateway: nil }
            ],
            config_map: nil
          }]
        }.deep_stringify_keys
      )
    end
  end

  context 'with numbered network' do
    let!(:numbered_actor) { create(:actor, :numbered, exercise:) }
    let!(:networks) { [create(:network, exercise:, actor: numbered_actor, cloud_id: 'hello{{ team_nr }}')] }

    it 'should list network with numbered instances' do
      expect(response).to be_successful
      expect(response.parsed_body).to have_key('result')
      expect(response.parsed_body['result']).to include(
        {
          id: networks.first.slug,
          name: networks.first.name,
          description: nil,
          actor: numbered_actor.abbreviation.downcase,
          instances: [{
            team_nr: 1,
            cloud_id: 'hello1',
            domains: [],
            address_pools: [
              { id: 'default-ipv4', ip_family: 'v4', network_address: '', gateway: nil },
              { id: 'default-ipv6', ip_family: 'v6', network_address: '', gateway: nil }
            ],
            config_map: nil
          }, {
            team_nr: 2,
            cloud_id: 'hello2',
            domains: [],
            address_pools: [
              { id: 'default-ipv4', ip_family: 'v4', network_address: '', gateway: nil },
              { id: 'default-ipv6', ip_family: 'v6', network_address: '', gateway: nil }
            ],
            config_map: nil
          }, {
            team_nr: 3,
            cloud_id: 'hello3',
            domains: [],
            address_pools: [
              { id: 'default-ipv4', ip_family: 'v4', network_address: '', gateway: nil },
              { id: 'default-ipv6', ip_family: 'v6', network_address: '', gateway: nil }
            ],
            config_map: nil
          }]
        }.deep_stringify_keys
      )
    end
  end

  context 'without headers' do
    let(:headers) { {} }

    it 'should return 401' do
      expect(response).to_not be_successful
      expect(response.status).to eq 401
    end
  end

  context 'with headers for a different exercise' do
    let!(:user) { create(:user, api_tokens: [api_token], permissions: Hash[-1, ['local_admin']]) }

    it 'should return 404' do
      expect(response).to_not be_successful
      expect(response.status).to eq 404
    end
  end
end
