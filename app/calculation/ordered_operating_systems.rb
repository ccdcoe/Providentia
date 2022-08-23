# frozen_string_literal: true

class OrderedOperatingSystems < Patterns::Calculation
  private
    def result
      build_array(subject.order('lower(name) asc').arrange)
    end

    def build_array(hash)
      hash.flat_map do |root, subtree|
        if subtree.empty?
          root
        else
          [root, Naturally.sort(build_array(subtree), by: :downcased_name)].flatten
        end
      end
    end
end
