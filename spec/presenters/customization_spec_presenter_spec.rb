# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::V3::CustomizationSpecPresenter do
  subject { described_class.new(spec).as_json }
  let(:spec) { create(:customization_spec) }

  context 'tags' do
    it 'should contain OS and actor tags' do
      expect(subject[:tags]).to eq([
        spec.virtual_machine.operating_system.api_short_name,
        ActorAPIName.result_for(spec.virtual_machine.actor)
      ])
    end

    context 'with nested os and actor' do
      let(:actor) { create(:actor, parent: create(:actor)) }
      let(:operating_system) { create(:operating_system, parent: create(:operating_system)) }
      let(:virtual_machine) { create(:virtual_machine, operating_system:, actor:) }
      let(:spec) { create(:customization_spec, virtual_machine:) }

      it 'should contain entire paths for both' do
        expect(subject[:tags]).to eq([
          spec.virtual_machine.operating_system.parent.api_short_name,
          spec.virtual_machine.operating_system.api_short_name,
          ActorAPIName.result_for(spec.virtual_machine.actor.parent),
          ActorAPIName.result_for(spec.virtual_machine.actor)
        ])
      end
    end
  end
end
