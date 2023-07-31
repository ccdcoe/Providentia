# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActorAPIName do
  subject { described_class.result_for(actor) }
  let(:actor) { build(:actor, abbreviation:) }
  let(:abbreviation) { 'default' }

  it { is_expected.to eq('actor_default') }

  describe 'with uppercase abbreviation' do
    let(:abbreviation) { 'DEFAULT' }

    it { is_expected.to eq('actor_default') }
  end

  describe 'with mixed symbol abbreviation' do
    let(:abbreviation) { 'Steinway & Sons / Faraday consulting' }

    it { is_expected.to eq('actor_steinway_sons_faraday_consulting') }
  end

  describe 'with number, example 1' do
    subject { described_class.result_for(actor, number: 4) }

    it { is_expected.to eq('actor_default_t04') }
  end

  describe 'with number, example 2' do
    subject { described_class.result_for(actor, number: 20) }

    it { is_expected.to eq('actor_default_t20') }
  end

  describe 'with secondary actor for numbering' do
    subject { described_class.result_for(actor, numbered_by:) }

    let(:numbered_by) { build(:actor, abbreviation: 'second') }

    it { is_expected.to eq('actor_default_second_numbered') }

    context 'including number' do
      subject { described_class.result_for(actor, numbered_by:, number: 20) }

      it { is_expected.to eq('actor_default_second_numbered_t20') }
    end
  end
end
