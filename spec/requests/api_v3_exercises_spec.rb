# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API v3 exercises', type: :request do
  let(:exercise) { create(:exercise) }
  let!(:numbered_actor) { create(:actor, :numbered, exercise:) }

  let!(:user) { create(:user, api_tokens: [api_token], permissions: Hash[exercise.id, ['local_admin']]) }
  let(:api_token) { create(:api_token) }
  let(:headers) { { 'Authorization' => "Token #{api_token.token}" } }

  before { get "/api/v3/#{exercise.slug}", headers: }

  it 'lists exercise info' do
    expect(response).to be_successful
    expect(response.parsed_body).to have_key('result')
    expect(response.parsed_body['result']).to eq(
      {
        id: exercise.slug,
        name: exercise.name,
        description: exercise.description,
        actors: exercise.actors.reload.map do |actor|
          {
            id: actor.abbreviation,
            name: actor.name,
            numbered: { entries: actor.all_numbers },
            config_map: {}
          }
        end
      }.deep_stringify_keys
    )
  end

  context 'with number configs' do
    it 'lists exercise info' do
      expect(response).to be_successful
      expect(response.parsed_body).to have_key('result')
      expect(response.parsed_body['result']).to eq(
        {
          id: exercise.slug,
          name: exercise.name,
          description: exercise.description,
          actors: exercise.actors.reload.map do |actor|
            {
              id: actor.abbreviation,
              name: actor.name,
              numbered: { entries: actor.all_numbers },
              config_map: {}
            }
          end
        }.deep_stringify_keys
      )
    end
  end
end
