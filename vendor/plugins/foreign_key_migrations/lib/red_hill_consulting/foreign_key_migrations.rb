module RedHillConsulting
  module ForeignKeyMigrations
    def self.references_table_name(column_name, options)
      if options.has_key?(:references)
        options[:references]
      elsif column_name.to_s =~ /^(.*)_id$/
        ActiveRecord::Base.pluralized_table_name($1)
      end
    end

    module AbstractAdapter
      def self.included(base)
        base.class_eval do
          alias_method :initialize_without_fk_migrations, :initialize unless method_defined?(:initialize_without_fk_migrations)
          alias_method :initialize, :initialize_with_fk_migrations
        end
      end
      
      def initialize_with_fk_migrations(*args)
        initialize_without_fk_migrations(*args)
        self.class.class_eval do
          alias_method :add_column_without_fk_migrations, :add_column unless method_defined?(:add_column_without_fk_migrations)
          alias_method :add_column, :add_column_with_fk_migrations
        end
      end
      
      def add_column_with_fk_migrations(table_name, column_name, type, options = {})
        add_column_without_fk_migrations(table_name, column_name, type, options)
        references_table_name = RedHillConsulting::ForeignKeyMigrations.references_table_name(column_name, options)
        add_foreign_key(table_name, column_name, references_table_name, :id, options) if references_table_name
      end
    end

    module TableDefinition
      def self.included(base)
        base.class_eval do
          alias_method :column_without_fk_migrations, :column unless method_defined?(:column_without_fk_migrations)
          alias_method :column, :column_with_fk_migrations
        end
      end

      def column_with_fk_migrations(name, type, options = {})        
        column_without_fk_migrations(name, type, options)
        references_table_name = RedHillConsulting::ForeignKeyMigrations.references_table_name(name, options)
        foreign_key(name, references_table_name, :id, options) if references_table_name
        self
      end

      # Some people liked this; personally I've decided against using it but I'll keep it nonetheless
      def belongs_to(table, options = {})
        options = options.merge(:references => table)
        options[:on_delete] = options.delete(:dependent) if options.has_key?(:dependent)
        column("#{table.to_s.singularize}_id".to_sym, :integer, options)
      end
    end
  end
end
