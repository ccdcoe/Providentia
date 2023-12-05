# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPermissions do
  subject { described_class.result_for(list) }

  context 'invalid list' do
    let(:list) { [] }

    it { should be_falsy }
  end


  context 'invalid list' do
    let(:list) {
      [
        'asdblah'
      ]
    }

    it { should be_falsy }
  end

  context 'default list' do
    let(:list) {
      [
        "#{ENV['OIDC_RESOURCE_PREFIX']}CF_GT",
        "#{ENV['OIDC_RESOURCE_PREFIX']}CF_RT",
        "#{ENV['OIDC_RESOURCE_PREFIX']}Admin"
      ]
    }

    it 'should return admin permissions' do
      expect(subject).to eq admin: true
    end

    context 'with exercise present' do
      let(:exercise) { create(:exercise) }
      let(:list) {
        [
          "#{ENV['OIDC_RESOURCE_PREFIX']}#{exercise.dev_red_resource_name}",
          "#{ENV['OIDC_RESOURCE_PREFIX']}#{exercise.dev_resource_name}",
          "#{ENV['OIDC_RESOURCE_PREFIX']}Admin"
        ]
      }

      it 'should return admin permissions' do
        expect(subject).to be_a(Hash)
        expect(subject[:admin]).to eq true
        expect(subject[exercise.id]).to be_a(Array)
        expect(subject[exercise.id]).to include :gt
        expect(subject[exercise.id]).to include :rt
      end
    end
  end

  context 'different exercises list' do
    let!(:ls) { create(:exercise, abbreviation: 'ls') }
    let!(:xs) { create(:exercise, abbreviation: 'xs') }
    let(:list) {
      [
        "#{ENV['OIDC_RESOURCE_PREFIX']}LS_GT",
        "#{ENV['OIDC_RESOURCE_PREFIX']}XS_RT"
      ]
    }

    it 'should return admin permissions' do
      expect(subject).to be_a(Hash)
      expect(subject[:admin]).to eq false
      expect(subject[ls.id]).to eq [:gt]
      expect(subject[xs.id]).to eq [:rt]
    end
  end
end
