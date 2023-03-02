# frozen_string_literal: true

class ExerciseResourceUsage < Patterns::Calculation
  private
    def result
      results = {
        cpu: 0,
        ram: 0,
        primary_disk_size: 0
      }

      subject.virtual_machines.each_with_object(results) do |vm, results|
        instance_count = vm.host_spec.deployable_instances.size
        results[:ram] += (vm.ram || vm.operating_system&.applied_ram).to_i * instance_count
        results[:cpu] += (vm.cpu || vm.operating_system&.applied_cpu).to_i * instance_count
        results[:primary_disk_size] += (vm.primary_disk_size || vm.operating_system&.applied_primary_disk_size).to_i * instance_count
      end
      OpenStruct.new(results)
    end
end
