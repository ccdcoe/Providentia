# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ipv6Offset do
  let(:instance) { described_class.new(offset) }

  context 'with small offset' do
    let(:offset) { 100 }

    it 'should return offset' do
      expect(instance.offset).to eq 100
    end

    it 'should return hex value' do
      expect(instance.to_s).to eq '64'
    end
  end

  context 'with large offset' do
    let(:offset) { 281483566841860 }

    it 'should return compressed offset' do
      expect(instance.to_s).to eq '1:2:3:4'
    end
  end

  context 'with offset 0' do
    let(:offset) { 0 }

    it 'equal to empty string' do
      expect(instance.to_s).to eq ''
    end
  end

  context '.dump' do
    subject { described_class.dump(dumpable) }

    context 'with string' do
      let(:dumpable) { 'ffff:ffff' }

      it 'should return instance with parsed hex offset' do
        expect(subject).to eq 4294967295
      end
    end

    context 'with unequal hex string' do
      let(:dumpable) { '1:2:3:4' }

      it 'should return instance with parsed hex offset' do
        expect(subject).to eq 281483566841860
      end
    end

    context 'with ipv6offset' do
      let!(:dumpable) { Ipv6Offset.new(200) }

      it 'should return dumpable itself' do
        expect(described_class).to_not receive(:new)
        expect(subject).to eq dumpable.offset
      end
    end

    context 'with integer' do
      let(:dumpable) { 200 }

      it 'should return new instance with same offset' do
        expect(described_class).to receive(:new).with(dumpable).and_call_original
        expect(subject).to eq dumpable
      end
    end

    context 'with nil' do
      let(:dumpable) { nil }

      it 'should return nil' do
        expect(subject).to be_nil
      end
    end
  end
end
