# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CloneEnvironment do
  subject { described_class.result_for(source.id, options) }
  let(:source) { create(:exercise) }
  let!(:actor1) { create(:actor, exercise: source, name: 'Root') }
  let!(:actor2) { create(:actor, exercise: source, name: 'Child', parent: actor1) }
  let!(:actor3) { create(:actor, exercise: source, name: 'Child2', parent: actor2) }
  let(:options) {
    {
      name: 'Cloned exercise',
      abbreviation: 'CE'
    }
  }

  context 'cloning' do
    it { is_expected.to be_a(Exercise) }

    it 'should have new attributes' do
      expect(subject.name).to eq options[:name]
      expect(subject.abbreviation).to eq options[:abbreviation]
    end
  end

  context 'actors' do
    it 'should have cloned the actor with children' do
      new_root = subject.actors.detect { _1.name == actor1.name }
      new_child = subject.actors.detect { _1.name == actor2.name }
      new_sub_child = subject.actors.detect { _1.name == actor3.name }
      expect(new_root).to_not be_nil
      expect(new_child).to_not be_nil
      expect(new_child.parent).to eq(new_root)
      expect(new_sub_child).to_not be_nil
      expect(new_sub_child.parent).to eq(new_child)
    end

    context 'with numbered configuration' do
      let!(:actor1) { create(:actor, :numbered, exercise: source, name: 'Root') }
      let!(:config) { create(:actor_number_config, actor: actor1, matcher: [1], config_map: { hello: 'world' }) }

      it 'should clone numbered config' do
        new_root = subject.actors.detect { _1.name == actor1.name }

        expect(new_root.number).to eq actor1.number
        expect(new_root.actor_number_configs).to_not be_empty
        new_config = new_root.actor_number_configs.first
        expect(new_config.matcher).to eq config.matcher
        expect(new_config.config_map).to eq config.config_map
      end
    end
  end

  context 'vm' do
    context 'numberable' do
      let!(:actor1) { create(:actor, :numbered, exercise: source, name: 'Root') }
      let!(:config) { create(:actor_number_config, actor: actor1, matcher: [1], config_map: { hello: 'world' }) }
      let!(:source_vm) { create(:virtual_machine, exercise: source, actor: actor2, numbered_by: config) }

      it 'should clone vm with correct numberable config and actor' do
        new_vm = subject.virtual_machines.reload.find_by(name: source_vm.name)

        expect(new_vm.actor.name).to eq source_vm.actor.name
        expect(new_vm.numbered_by).to be_a(ActorNumberConfig)
        expect(new_vm.numbered_by.actor.name).to eq actor1.name
        expect(new_vm.numbered_by.name).to eq config.name
      end
    end
  end
end
