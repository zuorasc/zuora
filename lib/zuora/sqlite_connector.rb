require 'sqlite3'

module Zuora
  #Sqlite3 in memoroy connector to simulate Zuora in test environments
  class SqliteConnector
    cattr_accessor :db

    def initialize(model)
      @model = model
    end

    def query(sql)
      sql = sql.gsub /select .* from/, 'select * from'
      result = db.query sql
      hashed_result = result.map {|r| hash_result_row(r, result) }
      {
        :query_response => {
          :result => {
            :success => true,
            :size => result.count,
            :records => hashed_result
          }
        }
      }
    end

    def create
      table = self.class.table_name(@model.class)
      hash = @model.to_hash
      hash.delete(:id)
      keys = []
      values = []
      hash.each do |key, value|
        keys << key.to_s.camelize
        values << value.to_s
      end
      place_holder = ['?'] * keys.length
      keys = keys.join(', ')
      place_holder = place_holder.join(', ')
      insert = "INSERT into '#{table}'(#{keys}) VALUES(#{place_holder})"
      db.execute insert, values
      new_id = db.last_insert_row_id
      {
        :create_response => {
          :result => {
            :success => true,
            :id => new_id
          }
        }
      }
    end

    def update
      table  = self.class.table_name(@model.class)
      hash   = @model.to_hash
      id     = hash.delete(:id)
      keys   = []
      values = []
      hash.each do |key, value|
        keys << "#{key.to_s.camelize}=?"
        values << value.to_s
      end
      keys   = keys.join(', ')
      update = "UPDATE '#{table}' SET #{keys} WHERE ID=#{id}"
      db.execute update, values
      {
        :update_response => {
          :result => {
            :success => true,
            :id => id
          }
        }
      }
    end

    def destroy
      table = self.class.table_name(@model.class)
      destroy = "DELETE FROM '#{table}' WHERE Id=?"
      db.execute destroy, @model.id
      {
        :delete_response => {
          :result => {
            :success => true,
            :id => @model.id
          }
        }
      }
    end

    def subscribe
      [
        :account,
        :subscription,
        :bill_to_contact,
        :payment_method,
        :sold_to_contact,
        :product_rate_plan
      ].each do |relation|
        obj = @model.send(relation)
        if obj
          if obj.new_record?
            obj.create
          else
            obj.update
          end
        end
      end

      {
        :subscribe_response => {
          :result => {
            :success => true,
            :id => nil
          }
        }
      }
    end

    def parse_attributes(type, attrs = {})
      data = attrs.to_a.map do |a|
        key, value = a
        [key.underscore, value]
      end
      Hash[data]
    end

    def self.build_schema
      self.db = SQLite3::Database.new ":memory:"
      self.generate_tables
    end

    def self.table_name(model)
      model.name.demodulize
    end

    protected

    def hash_result_row(row, result)
      row = row.map {|r| r.nil? ? "" : r }
      Hash[result.columns.zip(row.to_a)]
    end

    def self.generate_tables
      Zuora::Objects.constants.select { |c| c != :Base }.each do |model|
        create_table(Zuora::Objects.const_get(model))
      end
    end

    def self.create_table(model)
      table_name = self.table_name(model)
      attributes = model.attributes - [:id]
      attributes = attributes.map do |a|
        "'#{a.to_s.camelize}' text"
      end
      autoid = "'Id' integer primary key autoincrement"
      attributes.unshift autoid
      attributes = attributes.join(", ")
      schema = "CREATE TABLE 'main'.'#{table_name}' (#{attributes});"
      db.execute schema
    end

  end
end
