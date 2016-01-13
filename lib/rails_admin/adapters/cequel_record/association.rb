module RailsAdmin
  module Adapters
    module CequelRecord
      class Association
        attr_reader :association, :model

        def initialize(association, model)
          @association = association
          @model = model
        end

        def name
          association.name.to_sym
        end

        def pretty_name
          name.to_s.tr('_', ' ').capitalize
        end

        def type
          association.macro
        end

        def klass
          association.klass
        end

        def primary_key
          (options[:primary_key] || association.klass.primary_key).try(:to_sym) unless polymorphic?
        end

        def foreign_key
          association.foreign_key.to_sym
        end

        def foreign_key_nullable?
          return true if foreign_key.nil? || type != :has_many
          (column = klass.columns_hash[foreign_key.to_s]).nil? || column.null
        end

        def foreign_type
          options[:foreign_type].try(:to_sym) || :"#{name}_type" if options[:polymorphic]
        end

        def select
          [association]
        end

        def detect
          association
        end

        def foreign_inverse_of
          nil
        end

        def as
          options[:as].try :to_sym
        end

        def polymorphic?
          false
        end

        def inverse_of
          options[:inverse_of].try :to_sym
        end

        def read_only?
          (klass.all.instance_eval(&scope).readonly_value if scope.is_a? Proc) ||
            association.nested? ||
            false
        end

        def nested_options
          model.nested_attributes_options.try { |o| o[name.to_sym] }
        end

        def association?
          true
        end

        delegate :options, :scope, to: :association, prefix: false
        delegate :polymorphic_parents, to: RailsAdmin::AbstractModel
      end
    end
  end
end
