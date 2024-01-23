# frozen_string_literal: true

class SegmentDeployCountChipComponent < ViewComponent::Base
  attr_reader :title, :value, :css_color_classes

  def initialize(vm:, network:)
    @vm = vm
    @network = network

    generate_attributes
  end

  def render?
    numbered_by_sequential? || network_not_numbered_and_actor_is_numbered?
  end

  private
    def numbered_by_sequential?
      @vm.custom_instance_count.to_i > 1
    end

    def network_not_numbered_and_actor_is_numbered?
      !@network.numbered? && @vm.deploy_count > 1
    end

    def generate_attributes
      if numbered_by_sequential?
        @title = 'Custom instance count'
        @value = @vm.custom_instance_count - 1
        @css_color_classes = 'bg-green-100 text-green-500'
      elsif network_not_numbered_and_actor_is_numbered?
        @title = I18n.t('deploy_modes.per_item', item: @vm.numbered_actor.name)
        @value = @vm.deploy_count - 1
        @css_color_classes = 'bg-indigo-100 text-indigo-500'
      end
    end
end
