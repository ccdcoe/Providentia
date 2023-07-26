# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AddressPool do
  subject { build(:address_pool, network:) }
  let(:network) { build(:network) }

  context 'dynamic last octet' do
    let(:network) { build(:network, actor: build(:actor, :numbered)) }
    subject { build(:address_pool, network_address: '1.0.0.{{ team_nr }}/28', network:) }

    it 'should generate correctly numbered network segments' do
      expect(subject.ip_network(1).to_string).to eq '1.0.0.0/28'
      expect(subject.ip_network(2).to_string).to eq '1.0.0.16/28'
      expect(subject.ip_network(3).to_string).to eq '1.0.0.32/28'
    end
  end
end
