# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateTags do
  subject { described_class.result_for(source_objects) }

  context 'for Network' do
    let(:source_objects) { [network] }
    let(:network) { create(:network, domain: 'yahoo') }

    let(:default_result) {
      {
        id: network.api_short_name,
        name: network.name,
        config_map: {
          domain: network.full_domain
        },
        children: [],
        priority: 40
      }
    }

    it { is_expected.to eq([default_result]) }
  end

  context 'for OS' do
    let(:source_objects) { [operating_system] }
    let(:operating_system) { create(:operating_system) }

    let(:default_result) {
      {
        id: operating_system.api_short_name,
        name: operating_system.name,
        config_map: {},
        children: [],
        priority: 10
      }
    }

    it { is_expected.to eq([default_result]) }

    context 'with children' do
      let!(:another_os) { create(:operating_system, parent: operating_system) }

      it { is_expected.to include(default_result.merge(children: [another_os.api_short_name])) }
    end
  end

  context 'for Capability' do
    let(:source_objects) { [capability] }
    let(:capability) { build(:capability) }

    let(:default_result) {
      {
        id: "capability_#{capability.slug}".to_url.tr('-', '_'),
        name: capability.name,
        config_map: {},
        children: [],
        priority: 20
      }
    }

    it { is_expected.to eq([default_result]) }
  end

  context 'for customization specs' do
    let(:source_objects) { [customization_spec] }
    let(:customization_spec) { build(:customization_spec) }

    it { is_expected.to eq([]) }

    context 'as non-host spec' do
      let(:customization_spec) { build(:customization_spec, mode: :container) }
      let(:result) {
        [
          {
            id: 'customization_container',
            name: 'customization_container',
            config_map: {},
            children: [],
            priority: 45
          }
        ]
      }

      it { is_expected.to eq(result) }
    end


    context 'overarching group of all instances (sequential)' do
      let(:customization_spec) { create(:customization_spec, virtual_machine:) }
      let(:virtual_machine) { create(:virtual_machine, custom_instance_count: 10) }

      let(:overarching) {
        [
          {
            id: customization_spec.slug.tr('-', '_'),
            name: "All instances of #{customization_spec.slug}",
            config_map: {},
            children: [],
            priority: 40
          }
        ]
      }

      it { is_expected.to eq(overarching) }
    end

    context 'overarching group of all instances (numbered)' do
      let(:customization_spec) { create(:customization_spec, virtual_machine:) }
      let(:virtual_machine) { create(:virtual_machine, numbered_by: create(:actor, :numbered)) }

      let(:overarching) {
        [
          {
            id: customization_spec.slug.tr('-', '_'),
            name: "All instances of #{customization_spec.slug}",
            config_map: {},
            children: [],
            priority: 40
          }
        ]
      }

      it { is_expected.to eq(overarching) }
    end

    context 'custom tags' do
      let(:customization_spec) { build(:customization_spec, tag_list: 'Steinway & Sons, regular') }

      it 'should return with entry for each custom tag' do
        expect(subject.length).to eq 2
        expect(subject).to include({
          id: 'custom_steinway_and_sons',
          name: 'Custom tag steinway_and_sons',
          config_map: {},
          children: [],
          priority: 50
        })
        expect(subject).to include({
          id: 'custom_regular',
          name: 'Custom tag regular',
          config_map: {},
          children: [],
          priority: 50
        })
      end
    end
  end

  context 'for Actor' do
    let(:source_objects) { [actor] }
    let(:actor) { create(:actor) }

    let(:default_result) {
      {
        name: actor.name,
        id: ActorAPIName.result_for(actor),
        config_map: {},
        children: [],
        priority: 30
      }
    }

    it { is_expected.to eq([default_result]) }

    context 'with actor tree' do
      let!(:child_actor) { create(:actor, parent: actor) }

      it { is_expected.to eq([default_result.merge(children: [ActorAPIName.result_for(child_actor)])]) }
    end

    # context 'with networks belongign to the actor' do
    #   let!(:networks) { create_list(:network, 2, actor:) }

    #   it { is_expected.to eq([default_result.merge(children: networks.map(&:api_short_name))]) }
    # end

    context 'with legacy team id' do
      let(:actor) { create(:actor, abbreviation: 'gt') }

      it { is_expected.to eq([default_result, {
        id: 'team_green',
        name: 'Green',
        config_map: { team_color: 'Green' },
        children: [],
        priority: 30
      }])}
    end

    context 'if numbered' do
      let(:actor) { create(:actor, :numbered) }

      it {
        numbered_results = actor.all_numbers.map do |nr|
          {
            id: ActorAPIName.result_for(actor, number: nr),
            name: "#{actor.name} number #{nr}",
            children: [],
            config_map: {},
            priority: 30
          }
        end
        is_expected.to eq(
          [default_result.merge(children: numbered_results.map { |item| item[:id] })] +
          numbered_results
        )
      }

      context 'actor numbered config exists' do
        before { actor.save }
        before { create(:actor_number_config, actor:, matcher: [1], config_map: { hello: 'world' }) }

        it 'should contain the config map in numbered group' do
          expect(subject).to include({
            id: ActorAPIName.result_for(actor, number: 1),
            name: "#{actor.name} number 1",
            children: [],
            config_map: {
              'hello' => 'world'
            },
            priority: 30
          })
        end

        it 'should merge configs, if multiple are present' do
          create(:actor_number_config, actor:, matcher: [1], config_map: { another: 'one' })
          expect(subject).to include({
            id: ActorAPIName.result_for(actor, number: 1),
            name: "#{actor.name} number 1",
            children: [],
            config_map: {
              'hello' => 'world',
              'another' => 'one'
            },
            priority: 30
          })
        end
      end

      context 'if called with spec parameter' do
        subject { described_class.result_for(source_objects, spec: 'anything') }

        it { is_expected.to eq([default_result]) }
      end

      context 'with number configs' do
        let!(:config) {
          create(:actor_number_config,
            actor:,
            matcher: actor.all_numbers.take(2),
            config_map: { special: true }
          )
        }

        let!(:config2) {
          create(:actor_number_config,
            actor:,
            matcher: actor.all_numbers.take(2),
            config_map: { really_special: false }
          )
        }

        let(:numbered_results) {
          actor.all_numbers.map do |nr|
            map = config.config_map.merge(config2.config_map) if config.matcher.include?(nr.to_s)
            {
              id: ActorAPIName.result_for(actor, number: nr),
              name: "#{actor.name} number #{nr}",
              children: [],
              config_map: map || {},
              priority: 30
            }
          end
        }

        it { is_expected.to include(default_result.merge(children: numbered_results.map { |item| item[:id] })) }
        it { is_expected.to include(*numbered_results) }
      end
    end

    context 'as numbered actor for VM-s' do
      let(:actor) { create(:actor, :numbered, numbered_virtual_machines: numbered_vms) }
      let(:vm_primary_actor) { build(:actor, name: 'Primary', abbreviation: 'pr') }
      let(:numbered_vms) {
        build_list(:virtual_machine, 2, actor: vm_primary_actor)
      }

      let(:main_result) {
        {
          id: ActorAPIName.result_for(vm_primary_actor, numbered_by: actor),
          name: "#{vm_primary_actor.name}, numbered by #{actor.name}",
          config_map: {},
          children: numbered_results.map { |item| item[:id] },
          priority: 35
        }
      }
      let(:numbered_results) {
        actor.all_numbers.map do |nr|
          {
            id: ActorAPIName.result_for(vm_primary_actor, numbered_by: actor, number: nr),
            name: "#{vm_primary_actor.name}, numbered by #{actor.name} - number #{nr}",
            config_map: {},
            children: [],
            priority: 35
          }
        end
      }

      it { is_expected.to include(main_result) }
      it { is_expected.to include(*numbered_results) }

      context 'if not numbered' do
        let(:actor) { create(:actor) }

        pending
      end

      context 'if called with spec parameter' do
        subject { described_class.result_for(source_objects, spec: 'anything') }

        it { is_expected.to eq([default_result]) }
      end

      context 'with numbered configs' do
        let!(:config) {
          create(:actor_number_config,
            actor:,
            matcher: actor.all_numbers.take(2),
            config_map: { special: true }
          )
        }

        let!(:config2) {
          create(:actor_number_config,
            actor:,
            matcher: actor.all_numbers.take(2),
            config_map: { really_special: false }
          )
        }

        let(:numbered_results) {
          actor.all_numbers.map do |nr|
            map = config.config_map.merge(config2.config_map) if config.matcher.include?(nr.to_s)

            {
              id: ActorAPIName.result_for(vm_primary_actor, numbered_by: actor, number: nr),
              name: "#{vm_primary_actor.name}, numbered by #{actor.name} - number #{nr}",
              children: [],
              config_map: map || {},
              priority: 35
            }
          end
        }

        it { is_expected.to include(main_result) }
        it { is_expected.to include(*numbered_results) }
      end
    end
  end

  context 'for InstancePresenter', focus: true do
    let(:source_objects) { [presenter] }
    let(:presenter) { API::V3::InstancePresenter.new(customization_spec) }
    let(:customization_spec) { build(:customization_spec) }

    it { is_expected.to eq([]) }

    context 'with numbered spec and team number' do
      let(:numbered_actor) { build(:actor, number: 3) }
      let(:vm) { build(:virtual_machine, numbered_by: numbered_actor)}
      let(:customization_spec) { create(:customization_spec, virtual_machine: vm) }
      let(:presenter) { API::V3::InstancePresenter.new(customization_spec, nil, 1) }

      let(:result) {
        {
          id: ActorAPIName.result_for(vm.actor, number: 1, numbered_by: numbered_actor),
          name: "#{vm.actor.name}, numbered by #{numbered_actor.name} - number 1",
          children: [],
          config_map: {}
        }
      }

      it { is_expected.to eq([result]) }

      context 'if numbered within subtree of vm actor' do
        let(:root_actor) { create(:actor) }
        let(:actor) { create(:actor, number: 3, parent: root_actor) }
        let(:vm) { create(:virtual_machine, numbered_by: root_actor, actor:)}

        let(:result) {
          {
            id: ActorAPIName.result_for(actor, number: 1),
            name: "#{actor.name} number 1",
            children: [],
            config_map: {}
          }
        }

        let(:root_result) {
          {
            id: ActorAPIName.result_for(root_actor, number: 1),
            name: "#{root_actor.name} number 1",
            children: [],
            config_map: {}
          }
        }

        it { is_expected.to include(root_result) }
        it { is_expected.to include(result) }
      end
    end
  end
end
