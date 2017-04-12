class Reply < ModelBase

  attr_accessor :question_id, :parent_id, :author_id, :body

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @author_id = options['author_id']
    @body = options['body']
  end

  def self.table_name
    'replies'
  end

  def self.find_by_user_id(author_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        replies
      WHERE
        author_id = ?
    SQL
    data.map{|datum| Reply.new(datum)}
  end

  def self.find_by_question_id(question_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    data.map{|datum| Reply.new(datum)}
  end

  def author
    User.find_by_id(@author_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    return nil if @parent_id.nil?
    Reply.find_by_id(@parent_id)
  end

  def child_replies
    data = QuestionDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL
    data.map{|datum| Reply.new(datum)}
  end
end
