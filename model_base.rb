class ModelBase

  def self.find_by_id(id)
    data = QuestionDBConnection.instance.execute(<<-SQL, @@table, id)
      SELECT
        *
      FROM
        ?
      WHERE
        id = ?
    SQL
    self.new(data.first)
  end

end
