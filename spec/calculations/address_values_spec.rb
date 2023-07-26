# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AddressValues do
  subject { described_class.result_for(address) }
  let(:address) { build(:address, network:, address_pool:) }
  let(:network) { build(:network) }
  let(:address_pool) { build(:address_pool, network:) }

  context 'with regular address' do
    it { is_expected.to be_nil }
  end

  context 'and dynamic last octet' do
    let(:address_pool) { build(:address_pool, network_address: '1.0.0.{{ team_nr }}/27', network:) }

    it { is_expected.to be_nil }

    context 'with address network on numbered actor (3)' do
      let(:network) { build(:network, actor: build(:actor, :numbered)) }

      it { is_expected.to eq '(1.0.0.1, 1.0.0.33 ... 1.0.0.65)' }
    end

    context 'with address network on numbered actor (2)' do
      let(:network) { build(:network, actor: build(:actor, :numbered_2)) }

      it { is_expected.to eq '(1.0.0.1, 1.0.0.33)' }
    end
  end
end
