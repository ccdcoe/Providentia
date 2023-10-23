# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LiquidRangeSubstitution do
  subject { described_class.result_for(source_object, node:) }
  let(:node) { Liquid::Template.parse(input_string).root.nodelist.group_by(&:class)[Liquid::Variable][0] }

  context 'vm' do
    let(:source_object) { build(:virtual_machine) }

    context 'with team number node' do
      let(:input_string) { '{{ team_nr }}' }

      it { is_expected.to eq 'team_nr: N/A' }

      context 'with numbered actor' do
        let(:source_object) { build(:virtual_machine, actor: build(:actor, :numbered)) }

        it { is_expected.to eq "team_nr: 1 - #{source_object.actor.number}" }
      end

      context 'with numbering actor' do
        let(:source_object) { build(:virtual_machine, numbered_by: build(:actor, :numbered)) }

        it { is_expected.to eq "team_nr: 1 - #{source_object.numbered_by.number}" }
      end
    end
  end
end
