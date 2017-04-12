class QuestionLike < ModelBase
  attr_accessor :user_id, :question_id

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def self.table_name
    'question_likes'
  end

  def self.likers_for_question_id(question_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      JOIN
        question_likes ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL

    data.map{|datum| User.new(datum)}
  end

  def self.num_likes_for_question_id(question_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*) AS like_count
      FROM
        users
      JOIN
        question_likes ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL

    data.first['like_count']
  end

  def self.liked_questions_for_user_id(user_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_likes ON questions.id = question_likes.question_id
      WHERE
        user_id = ?
    SQL

    data.map{|datum| Question.new(datum)}
  end

  def self.most_liked_questions(n)
    data = QuestionDBConnection.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
        JOIN
          (
            SELECT
              question_id, COUNT(user_id) AS users
            FROM
              question_likes
            GROUP BY
              question_id
          ) AS like_count ON questions.id = like_count.question_id
      ORDER BY
        users
      LIMIT
        ?
    SQL
    data.map { |datum| Question.new(datum) }
  end
end
