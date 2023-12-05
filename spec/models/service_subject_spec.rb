# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceSubject do
  context 'spec cache' do
    subject { create(:service_subject, service:) }
    let(:service) { create(:service) }
    let(:virtual_machine) { create(:virtual_machine, exercise: service.exercise) }

    it 'should set correct cache when matcher condition added' do
      service.service_subjects.reload
      subject.match_conditions = [ServiceSubjectMatchCondition.new(
        matcher_type: 'CustomizationSpec', matcher_id: virtual_machine.host_spec.id
      )]
      subject.save
      subject.match_conditions[0].matcher_id = virtual_machine.host_spec.id
      subject.save
      subject.reload

      expect(subject.customization_spec_ids).to eq ([virtual_machine.host_spec.id])
    end

    context 'with a pre-existing match condition' do
      subject {
        create(:service_subject, service:, match_conditions: [ServiceSubjectMatchCondition.new(
          matcher_type: 'CustomizationSpec', matcher_id: virtual_machine.host_spec.id
        )])
      }

      let(:virtual_machine2) { create(:virtual_machine, exercise: service.exercise) }

      it 'should update cache when changing matcher id' do
        subject.match_conditions[0].matcher_id = virtual_machine2.host_spec.id
        subject.save

        expect(subject.customization_spec_ids).to eq ([virtual_machine2.host_spec.id])
      end

      it 'should update cache key for previous vms when changing matcher id' do
        subject.match_conditions[0].matcher_id = virtual_machine2.host_spec.id

        expect {
          subject.save
          virtual_machine.host_spec.reload
        }.to change(virtual_machine.host_spec, :cache_key_with_version)
      end

      it 'should update cache key for following vms when changing matcher id' do
        subject.match_conditions[0].matcher_id = virtual_machine2.host_spec.id

        expect {
          subject.save
          virtual_machine2.host_spec.reload
        }.to change(virtual_machine2.host_spec, :cache_key_with_version)
      end

      it 'should empty cached ids when deleting matcher' do
        subject.match_conditions[0].matcher_id = nil
        subject.save
        expect(subject.customization_spec_ids).to eq ([])
      end

      it 'should update cache key for previous vms when deleting matcher id' do
        subject.match_conditions[0].matcher_id = nil

        expect {
          subject.save
          virtual_machine.host_spec.reload
        }.to change(virtual_machine.host_spec, :cache_key_with_version)
      end

      it 'should update cache key for previous vms when deleting subject' do
        expect {
          subject.destroy
          virtual_machine.host_spec.reload
        }.to change(virtual_machine.host_spec, :cache_key_with_version)
      end
    end
  end
end
