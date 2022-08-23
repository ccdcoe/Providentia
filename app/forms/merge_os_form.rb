# frozen_string_literal: true

class MergeOsForm < Patterns::Form
  param_key 'merge_os'

  attribute :source_id, Integer
  attribute :destination_id, Integer

  validate :source_not_same_as_destination

  private
    def source_not_same_as_destination
      errors.add(:destination_id, :invalid) if source_id == destination_id
    end

    def persist
      OperatingSystem.transaction do
        OperatingSystem
          .find(source_id)
          .virtual_machines
          .update_all(operating_system_id: destination_id)

        OperatingSystem.find(source_id).destroy
      end
    end
end
