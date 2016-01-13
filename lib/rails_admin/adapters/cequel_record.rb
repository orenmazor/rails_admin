require 'rails_admin/adapters/cequel_record/property'
require 'rails_admin/adapters/cequel_record/association'

module RailsAdmin
  module Adapters
    module CequelRecord

      delegate :primary_key, :table_name, to: :model, prefix: false
      DISABLED_COLUMN_TYPES = []

      def new(params = {})
        AbstractObject.new(model.new(params))
      end

      def get(id)
        return unless object = model.where(primary_key => id).first
        AbstractObject.new object
      end

      def scoped
        model.all
      end

      def first(options = {}, scope = nil)
        all(options, scope).first
      end

      def all(options = {}, scope = nil)
        scope ||= scoped
        scope = scope.includes(options[:include]) if options[:include]
        scope = scope.limit(options[:limit]) if options[:limit]
        scope = scope.where(primary_key => options[:bulk_ids]) if options[:bulk_ids]
        scope = query_scope(scope, options[:query]) if options[:query]
        scope = filter_scope(scope, options[:filters]) if options[:filters]
        if options[:page] && options[:per]
          scope = scope.send(Kaminari.config.page_method_name, options[:page]).per(options[:per])
        end
        scope
      end

      def count(options = {}, scope = nil)
        all(options.merge(limit: false, page: false), scope).count()
      end

      def destroy(objects)
        Array.wrap(objects).each(&:destroy)
      end

      def associations
        model.child_associations.collect do |association|
          Association.new(association.second, model)
        end

        # #cequel supports only has one belongs_to
        # Association.new(model.parent_association, model)
      end

      def properties
        model.columns.collect do |property|
          Property.new(property, model)
        end
      end

      def embedded?
        false
      end

      def cyclic?
        false
      end

      def adapter_supports_joins?
        true
      end

      private


    end
  end
end
