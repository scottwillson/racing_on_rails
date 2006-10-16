module RedHillConsulting
  module Core
    module Base
      def self.extended(base)
        class << base
          alias_method :columns_without_redhillonrails_core, :columns unless method_defined?(:columns_without_redhillonrails_core)
          alias_method :columns, :columns_with_redhillonrails_core

          alias_method :abstract_class_without_redhillonrails_core?, :abstract_class? unless method_defined?(:abstract_class_without_redhillonrails_core?)
          alias_method :abstract_class?, :abstract_class_with_redhillonrails_core?
        end
      end
      
      def base_class?
        self == base_class
      end

      def abstract_class_with_redhillonrails_core?
        abstract_class_without_redhillonrails_core? || !(name =~ /^Abstract/).nil?
      end

      def columns_with_redhillonrails_core
        unless @columns
          columns_without_redhillonrails_core
          cols = columns_hash
          indexes.each do |index|
            next unless index.unique
            column_name = index.columns.reverse.detect { |name| name !~ /_id$/ } || index.columns.last
            column = cols[column_name]
            column.unique_scope = index.columns.reject { |name| name == column_name }
          end
        end
        @columns
      end

      def pluralized_table_name(table_name)
        ActiveRecord::Base.pluralize_table_names ? table_name.to_s.pluralize : table_name
      end

      def indexes
        @indexes ||= connection.indexes(table_name, "#{name} Indexes")
      end

      def foreign_keys
        @foreign_keys ||= connection.foreign_keys(table_name, "#{name} Foreign Keys")
      end

      def reverse_foreign_keys
        @reverse_foreign_keys ||= connection.reverse_foreign_keys(table_name, "#{name} Reverse Foreign Keys")
      end
    end

    module AbstractAdapter
      def foreign_keys(table_name, name = nil)
        []
      end

      def reverse_foreign_keys(table_name, name = nil)
        []
      end

      def add_foreign_key(table_name, column_names, references_table_name, references_column_names, options = {})
        foreign_key = ForeignKeyDefinition.new(column_names, ActiveRecord::Migrator.proper_table_name(references_table_name), references_column_names, options[:on_update], options[:on_delete])
        execute "ALTER TABLE #{table_name} ADD #{foreign_key}"
      end
      
      def remove_foreign_key(table_name, foreign_key_name)
        execute "ALTER TABLE #{table_name} DROP FOREIGN KEY #{foreign_key_name}"
      end
    end

    module TableDefinition
      def self.included(base)
        base.class_eval do
          alias_method :initialize_without_redhillonrails_core, :initialize unless method_defined?(:initialize_without_redhillonrails_core)
          alias_method :initialize, :initialize_with_redhillonrails_core

          alias_method :to_sql_without_redhillonrails_core, :to_sql unless method_defined?(:to_sql_without_redhillonrails_core)
          alias_method :to_sql, :to_sql_with_redhillonrails_core
        end
      end

      def initialize_with_redhillonrails_core(*args)
        initialize_without_redhillonrails_core(*args)
        @foreign_keys = []
      end

      def foreign_key(column_names, references_table_name, references_column_names, options = {})
        @foreign_keys << ForeignKeyDefinition.new(column_names, ActiveRecord::Migrator.proper_table_name(references_table_name), references_column_names, options[:on_update], options[:on_delete])
        self
      end

      def to_sql_with_redhillonrails_core
        sql = to_sql_without_redhillonrails_core
        sql << ', ' << @foreign_keys * ', ' unless @foreign_keys.empty? || ActiveRecord::Schema.defining?
        sql
      end
    end

    module Column
      attr_accessor :unique_scope
      
      def unique
        !unique_scope.nil?
      end
      
      def required
        !null && default.nil?
      end
    end

    class ForeignKeyDefinition < Struct.new(:column_names, :references_table_name, :references_column_names, :on_update, :on_delete)
      ACTIONS = { :cascade => "CASCADE", :restrict => "RESTRICT", :set_null => "SET NULL" }.freeze
      
      def to_sql
        sql = "FOREIGN KEY (#{Array(column_names).join(", ")}) REFERENCES #{references_table_name} (#{Array(references_column_names).join(", ")})"
        sql << " ON UPDATE #{ACTIONS[on_update]}" if on_update
        sql << " ON DELETE #{ACTIONS[on_delete]}" if on_delete
        sql
      end      
      alias :to_s :to_sql
    end

    class ForeignKey
      attr_reader :name, :table_name, :column_names, :references_table_name, :references_column_names, :on_update, :on_delete
      
      def initialize(name, table_name, column_names, references_table_name, references_column_names, on_update, on_delete)
        @name, @table_name, @column_names, @references_table_name, @references_column_names, @on_update, @on_delete = name, table_name, column_names, references_table_name, references_column_names, on_update, on_delete
      end
      
      def to_dump
        dump = "add_foreign_key"
        dump << " #{table_name.inspect}, [#{column_names.collect{ |name| name.inspect }.join(', ')}]"
        dump << ", #{references_table_name.inspect}, [#{references_column_names.collect{ |name| name.inspect }.join(', ')}]"
        dump << ", :on_update => :#{on_update}" if on_update
        dump << ", :on_delete => :#{on_delete}" if on_delete
        dump
      end
    end

    module Schema
      def self.extended(base)
        class << base
          attr_accessor :defining
          alias :defining? :defining

          alias_method :define_without_run_state, :define unless method_defined?(:define_without_run_state)
          alias_method :define, :define_with_run_state
        end
      end

      def define_with_run_state(info={}, &block)
        begin
          self.defining = true
          define_without_run_state(info, &block)
        ensure
          self.defining = false
        end
      end
    end

    module SchemaDumper
      def self.included(base)
        base.class_eval do
          private

          alias_method :tables_without_fk_migrations, :tables unless method_defined?(:tables_without_fk_migrations)
          alias_method :tables, :tables_with_fk_migrations
          alias_method :indexes_without_fk_migrations, :indexes unless method_defined?(:indexes_without_fk_migrations)
          alias_method :indexes, :indexes_with_fk_migrations
        end
      end
  
      private
  
      def tables_with_fk_migrations(stream)
        @foreign_keys = StringIO.new
        begin
          tables_without_fk_migrations(stream)
          @foreign_keys.rewind
          stream.print @foreign_keys.read
        ensure
          @foreign_keys = nil
        end
      end
  
      def indexes_with_fk_migrations(table, stream)
        indexes_without_fk_migrations(table, stream)
        foreign_keys(table, @foreign_keys)
      end
      
      def foreign_keys(table, stream)
        foreign_keys = @connection.foreign_keys(table)
        foreign_keys.each do |foreign_key|
          stream.print "  "
          stream.print foreign_key.to_dump
          stream.puts
        end
        stream.puts unless foreign_keys.empty?
      end
    end

    module PostgreSQLAdapter
      def foreign_keys(table_name, name = nil)
        results = query(<<-SQL,name)
          SELECT f.conname, pg_get_constraintdef(f.oid)
            FROM pg_class t, pg_constraint f
           WHERE f.conrelid = t.oid
             AND f.contype = 'f'
             AND t.relname = '#{table_name}'
        SQL

        foreign_keys = []

        results.each do |row|
          if row[1] =~ /^FOREIGN KEY \((.+?)\) REFERENCES (.+?)\((.+?)\)( ON UPDATE (.+?))?( ON DELETE (.+?))?$/
            name = row[0]
            column_names = $1
            references_table_name = $2
            references_column_names = $3
            on_update = $5
            on_delete = $7
            on_update = on_update.downcase.gsub(' ', '_').to_sym if on_update
            on_delete = on_delete.downcase.gsub(' ', '_').to_sym if on_delete

            foreign_keys << ForeignKey.new(name,
                                           table_name, column_names.split(', '),
                                           references_table_name, references_column_names.split(', '),
                                           on_update, on_delete)
          end
        end
        
        foreign_keys
      end

      def reverse_foreign_keys(table_name, name = nil)
        results = query(<<-SQL,name)
          SELECT f.conname, pg_get_constraintdef(f.oid), t2.relname
            FROM pg_class t, pg_class t2, pg_constraint f
           WHERE f.confrelid = t.oid
             AND f.conrelid = t2.oid
             AND f.contype = 'f'
             AND t.relname = '#{table_name}'
        SQL

        reverse_foreign_keys = []

        results.each do |row|
          if row[1] =~ /^FOREIGN KEY \((.+?)\) REFERENCES (.+?)\((.+?)\)( ON UPDATE (.+?))?( ON DELETE (.+?))?$/
            name = row[0]
            from_table_name = row[2]
            column_names = $1
            references_table_name = $2
            references_column_names = $3
            on_update = $5
            on_delete = $7
            on_update = on_update.downcase.gsub(' ', '_').to_sym if on_update
            on_delete = on_delete.downcase.gsub(' ', '_').to_sym if on_delete

            reverse_foreign_keys << ForeignKey.new(name,
                                           from_table_name, column_names.split(', '),
                                           references_table_name, references_column_names.split(', '),
                                           on_update, on_delete)
          end
        end
        
        reverse_foreign_keys
      end

      def remove_foreign_key(table_name, foreign_key_name)
        execute "ALTER TABLE #{table_name} DROP CONSTRAINT #{foreign_key_name}"
      end
    end
    
    module MysqlColumn
      def initialize(name, default, sql_type = nil, null = true)
        default = nil if !null && default.blank?
        super
      end
    end

    module MysqlAdapter
      def self.included(base)
        base.class_eval do
          alias_method :remove_column_without_redhillonrails_core, :remove_column unless method_defined?(:remove_column_without_redhillonrails_core)
          alias_method :remove_column, :remove_column_with_redhillonrails_core
        end
      end
      
      def remove_column_with_redhillonrails_core(table_name, column_name)
        foreign_keys(table_name).select { |foreign_key| foreign_key.column_names.include?(column_name.to_s) }.each do |foreign_key|
          remove_foreign_key(table_name, foreign_key.name)
        end
        remove_column_without_redhillonrails_core(table_name, column_name)
      end

      def foreign_keys(table_name, name = nil)
        results = execute("SHOW CREATE TABLE `#{table_name}`", name)

        foreign_keys = []

        results.each do |row|
          row[1].each do |line|
            if line =~ /^  CONSTRAINT `(.+?)` FOREIGN KEY \(`(.+?)`\) REFERENCES `(.+?)` \((.+?)\)( ON UPDATE (.+?))?( ON DELETE (.+?))?,?$/
              name = $1
              column_names = $2
              references_table_name = $3
              references_column_names = $4
              on_update = $6
              on_delete = $8
              on_update = on_update.downcase.gsub(' ', '_').to_sym if on_update
              on_delete = on_delete.downcase.gsub(' ', '_').to_sym if on_delete

              foreign_keys << ForeignKey.new(name,
                                             table_name, column_names.gsub('`', '').split(', '),
                                             references_table_name, references_column_names.gsub('`', '').split(', '),
                                             on_update, on_delete)
           end
         end
        end
        
        foreign_keys
      end
    end

    module SchemaStatements
      def self.included(base)
        base.module_eval do
          alias_method :drop_table_without_redhillonrails_core, :drop_table unless method_defined?(:drop_table_without_redhillonrails_core)
          alias_method :drop_table, :drop_table_with_redhillonrails_core
        end
      end

      def drop_table_with_redhillonrails_core(name)
        ActiveRecord::Base.connection.reverse_foreign_keys(name).each do |fk|
          ActiveRecord::Base.connection.remove_foreign_key(fk.table_name, fk.name)
        end
        drop_table_without_redhillonrails_core(name)
      end
    end
  end
end
