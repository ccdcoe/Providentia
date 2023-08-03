# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VirtualMachine do
  subject { build(:virtual_machine) }

  context '#deploy_count' do
    subject { build(:virtual_machine, numbered_by:).deploy_count }
    let(:numbered_by) { nil }

    it { is_expected.to eq 1 }

    context 'with non-numbered actor' do
      let(:numbered_by) { build(:actor) }

      it { is_expected.to eq 1 }
    end

    context 'with numbered actor' do
      let(:numbered_by) { build(:actor, :numbered) }

      it { is_expected.to eq numbered_by.number }
    end
  end
end
