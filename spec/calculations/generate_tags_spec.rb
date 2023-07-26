# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateTags do
  subject { described_class.result_for(source_objects) }

  context 'for Actor' do
    let(:source_objects) { [actor] }
    let(:actor) { build(:actor) }

    let(:default_result) {
      {
        name: actor.name,
        id: actor.api_short_name,
        config_map: {},
        children: []
      }
    }

    it { is_expected.to eq([default_result]) }

    context 'with legacy team id' do
      let(:actor) { build(:actor, abbreviation: 'gt') }

      it { is_expected.to eq([default_result, {
        id: 'team_green',
        name: 'Green',
        config_map: { team_color: 'Green' },
        children: []
      }])}
    end

    context 'if numbered' do
      let(:actor) { build(:actor, :numbered) }

      it {
        numbered_results = actor.all_numbers.map do |nr|
          {
            id: "#{actor.api_short_name}_t#{nr.to_s.rjust(2, "0")}",
            name: "#{actor.name} number #{nr}",
            children: [],
            config_map: {}
          }
        end
        is_expected.to eq(
          [default_result.merge(children: numbered_results.map { |item| item[:id] })] +
          numbered_results
        )
      }

      context 'if called with spec parameter' do
        subject { described_class.result_for(source_objects, spec: 'anything') }

        it { is_expected.to eq([default_result]) }
      end
    end

    context 'as numbered actor for VM-s' do
      let(:actor) { build(:actor, :numbered, numbered_virtual_machines: numbered_vms) }
      let(:vm_primary_actor) { build(:actor, name: 'Primary', abbreviation: 'pr') }
      let(:numbered_vms) {
        build_list(:virtual_machine, 2, actor: vm_primary_actor)
      }

      let(:main_result) {
        {
          id: "#{vm_primary_actor.api_short_name}_#{actor.abbreviation.downcase}_numbered",
          name: "#{vm_primary_actor.name}, numbered by #{actor.name}",
          config_map: {},
          children: numbered_results.map { |item| item[:id] }
        }
      }
      let(:numbered_results) {
        actor.all_numbers.map do |nr|
          {
            id: "#{vm_primary_actor.api_short_name}_#{actor.abbreviation.downcase}_numbered_t#{nr.to_s.rjust(2, "0")}",
            name: "#{vm_primary_actor.name}, numbered by #{actor.name} - number #{nr}",
            config_map: {},
            children: []
          }
        end
      }

      it { is_expected.to include(main_result) }
      it { is_expected.to include(*numbered_results) }

      context 'if not numbered' do
        let(:actor) { build(:actor) }

        pending
      end

      context 'if called with spec parameter' do
        subject { described_class.result_for(source_objects, spec: 'anything') }

        it { is_expected.to eq([default_result]) }
      end
    end
  end
end
