# frozen_string_literal: true

class UserPermissions < Patterns::Calculation
  ADMIN_RESOURCE_NAME = 'Admin'
  RESOURCE_REGEX = /^\/?#{Regexp.quote(Rails.configuration.resource_prefix)}/

  private
    def result
      return if filtered_list.empty?

      filtered_list.each_with_object({ admin: false }) do |resource, hash|
        if resource == ADMIN_RESOURCE_NAME
          hash[:admin] = true
        else
          Exercise.where(dev_resource_name: resource).each do |ex|
            hash[ex.id] ||= []
            hash[ex.id] << :gt
          end

          Exercise.where(dev_red_resource_name: resource).each do |ex|
            hash[ex.id] ||= []
            hash[ex.id] << :rt
          end

          Exercise.where(local_admin_resource_name: resource).each do |ex|
            hash[ex.id] ||= []
            hash[ex.id] << :local_admin
          end
        end
      end.symbolize_keys
    end

    def filtered_list
      (subject || []).filter_map do |resource|
        if resource.match? RESOURCE_REGEX
          resource.sub(RESOURCE_REGEX, '')
        end
      end
    end
end
