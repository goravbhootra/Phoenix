module Tree
  extend ActiveSupport::Concern

  included do
    has_ancestry orphan_strategy: :restrict
    def name_for_selects
      "#{'|' if depth > 0}" + "#{'---' * depth} #{name}"
    end

    def name_for_tree
      "<span class='tree_#{depth}'>#{name}</span>".html_safe
    end

    def possible_parents
      parents = self.class.arrange_as_array(order: 'name')
      return new_record? ? parents : parents - subtree
    end

    def self.arrange_as_array(options={}, hash=nil)
      hash ||= arrange(options) unless hash.is_a? Array

      arr = []

      hash.each do |node, children|
        arr << node
        arr += arrange_as_array(options, children) unless children.nil?
      end
      arr
    end

    def name_list(column='name')
      ancestors.pluck(column.to_sym).inject('') { |parents,x| parents + x + " --> " } + name
    end

    # def parent_enum
    #   where.not(id: id).map { |c| [ c.name, c.id ] }
    # end
  end

  # module ClassMethods
  #     def arrange_as_array(options={}, hash=nil)
  #         hash ||= arrange(options) unless hash.is_a? Array

  #         arr = []

  #         hash.each do |node, children|
  #             arr << node
  #             arr += arrange_as_array(options, children) unless children.nil?
  #         end
  #         arr
  #     end
  # end
end
