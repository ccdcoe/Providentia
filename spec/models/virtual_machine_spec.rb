# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VirtualMachine do
  subject { build(:virtual_machine) }

  context '#deploy_count' do
    subject { build(:virtual_machine, numbered_actor:).deploy_count }
    let(:numbered_actor) { nil }

    it { is_expected.to eq 1 }

    context 'with non-numbered actor' do
      let(:numbered_actor) { build(:actor) }

      it { is_expected.to eq 1 }
    end

    context 'with numbered actor' do
      let(:numbered_actor) { build(:actor, :numbered) }

      it { is_expected.to eq numbered_actor.number }
    end
  end
end
