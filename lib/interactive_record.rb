require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    columns = DB[:conn].execute("PRAGMA table_info(#{self.table_name})")

    columns.map do |column|
      column["name"]
    end.compact
  end

  def initialize(student_hash={})
    student_hash.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    names = []
    self.class.column_names.each do |name|
      names << name if name != "id"
    end
    names.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |name|
      values << "'#{send(name)}'" if send(name) != nil
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(attribute)
    att, val = attribute.first
    sql = "SELECT * FROM #{table_name} WHERE #{att} = '#{val}'"
    DB[:conn].execute(sql)
  end

end
