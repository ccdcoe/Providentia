# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomizationSpec do
  let(:spec) { build(:customization_spec) }

  context '#deployable_instances' do
    subject { spec.deployable_instances(presenter) }
    let(:presenter) { Struct.new(:spec, :sequential_number, :team_number) }

    it 'should generate single instance by default' do
      expect(subject.size).to eq 1
      expect(subject.first.team_number).to eq nil
      expect(subject.first.sequential_number).to eq nil
    end

    context 'with custom_instance_count on vm' do
      let(:spec) { build(:customization_spec, virtual_machine:) }
      let(:virtual_machine) { build(:virtual_machine, custom_instance_count: count) }
      let(:count) { 2 }

      it 'should generate single instance by default' do
        expect(subject.size).to eq 2
        expect(subject.map(&:team_number)).to all(be_nil)
        expect(subject.map(&:sequential_number)).to eq([1, 2])
      end

      context 'with single cluster' do
        let(:count) { 1 }

        it 'should generate single instance by default' do
          expect(subject.size).to eq 1
          expect(subject.map(&:team_number)).to all(be_nil)
          expect(subject.map(&:sequential_number)).to eq([1])
        end
      end
    end

    context 'with numbered actor as numbered_by' do
      let(:spec) { build(:customization_spec, virtual_machine:) }
      let(:virtual_machine) { build(:virtual_machine, numbered_by:) }
      let(:numbered_by) { build(:actor, :numbered) }

      it 'should generate single instance by default' do
        expect(subject.size).to eq numbered_by.number
        expect(subject.map(&:sequential_number)).to all(be_nil)
        expect(subject.map(&:team_number)).to eq(1.upto(numbered_by.number).to_a)
      end

      context 'with team numbering = 1' do
        let(:numbered_by) { build(:actor, :numbered, number: 1) }

        it 'should generate single instance by default' do
          expect(subject.size).to eq 1
          expect(subject.map(&:sequential_number)).to all(be_nil)
          expect(subject.map(&:team_number)).to all(be_nil)
        end
      end

      context 'with custom_instance_count' do
        let(:virtual_machine) { build(:virtual_machine, numbered_by:, custom_instance_count: 2) }

        it 'should generate single instance by default' do
          expect(subject.size).to eq numbered_by.number * 2

          numbered_by.all_numbers.product([1, 2]).each do |(team, seq)|
            expect(subject).to include(presenter.new(spec, seq, team))
          end
        end
      end
    end

    context 'with actor numbered config as numbered_by' do
      let(:spec) { build(:customization_spec, virtual_machine:) }
      let(:virtual_machine) { build(:virtual_machine, numbered_by:) }
      let(:numbered_by) { build(:actor_number_config, actor: nr_actor, matcher: [1]) }
      let(:nr_actor) { build(:actor, :numbered) }

      it 'should generate single instance by default' do
        expect(subject.size).to eq nr_actor.number
        expect(subject.map(&:sequential_number)).to all(be_nil)
        expect(subject.map(&:team_number)).to eq(1.upto(nr_actor.number).to_a)
      end

      context 'with custom_instance_count' do
        let(:virtual_machine) { build(:virtual_machine, numbered_by:, custom_instance_count: 2) }

        it 'should generate single instance by default' do
          expect(subject.size).to eq nr_actor.number * 2

          nr_actor.all_numbers.product([1, 2]).each do |(team, seq)|
            expect(subject).to include(presenter.new(spec, seq, team))
          end
        end
      end
    end
  end
end
