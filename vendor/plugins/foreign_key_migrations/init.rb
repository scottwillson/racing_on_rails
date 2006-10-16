ActiveRecord::ConnectionAdapters::AbstractAdapter.send(:include, RedHillConsulting::ForeignKeyMigrations::AbstractAdapter)
ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, RedHillConsulting::ForeignKeyMigrations::TableDefinition)
