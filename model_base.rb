require 'byebug'

class ModelBase

  def self.table_name
    nil
  end

  def self.find_by_id(id)
    table = self.table_name
    data = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table}
      WHERE
        id = ?
    SQL
    self.new(data.first)
  end

  def self.all
    table = self.table_name
    data = QuestionDBConnection.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table}
    SQL
    data.map{ |datum| self.new(datum) }
  end

  def save
    @id ? update : create
  end

  private

  def create
    raise "#{self} already in database" if @id
    table = self.class.table_name
    ivars = self.instance_variables[1..-1].map(&:to_s)
    var_values = ivars.map { |varname| instance_variable_get(varname) }
    num_vars = ivars.length
    str_vars = ivars.join(', ').delete('@')
    debugger
    QuestionDBConnection.instance.execute(<<-SQL, *var_values)
      INSERT INTO
        #{table} (#{str_vars})
      VALUES
        (#{'?, ' * (num_vars - 1) + '?'})
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    table = self.class.table_name
    ivars = self.instance_variables[1..-1].map(&:to_s)
    var_values = ivars.map { |varname| instance_variable_get(varname) }
    str_vars = ivars.join(' = ?, ').delete('@')
    QuestionDBConnection.instance.execute(<<-SQL, *var_values, @id)
      UPDATE
        #{table}
      SET
        #{str_vars} = ?
      WHERE
        id = ?
    SQL
  end
end
