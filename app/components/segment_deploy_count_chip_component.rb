# frozen_string_literal: true

class SegmentDeployCountChipComponent < ViewComponent::Base
  def initialize(vm:, network:)
    @vm = vm
    @network = network
  end

  def render?
    !vm_single_instance? && (
      @vm.custom_instance_count || !@network.numbered? && @vm.deploy_count > 1
    )
  end

  private
    def vm_single_instance?
      !@vm.numbered_actor && !@vm.custom_instance_count
    end

    def title
      if @vm.custom_instance_count
        'Custom instance count'
      elsif !@network.numbered? && @vm.deploy_count > 1
        I18n.t('deploy_modes.actor', actor: @vm.numbered_actor.name)
      end
    end

    def value
      if @vm.custom_instance_count
        @vm.custom_instance_count
      elsif !@network.numbered? && @vm.deploy_count > 1
        @vm.deploy_count
      end
    end

    def css_color_classes
      if @vm.custom_instance_count
        'bg-green-100 text-green-500'
      else
        'bg-indigo-100 text-indigo-500'
      end
    end
end
