class QuestionFollow
  @@table = 'question_follows'

  attr_accessor :question_id, :follower_id

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @follower_id = options['follower_id']
  end

  def self.find_by_id(id)
    data = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
    QuestionFollow.new(data.first)
  end

  def self.followers_for_question_id(question_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
        JOIN
          question_follows ON users.id = question_follows.follower_id
      WHERE
        question_id = ?
    SQL
    data.map { |datum| User.new(datum) }
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
        JOIN
          question_follows ON questions.id = question_follows.question_id
      WHERE
        follower_id = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed_questions(n)
    data = QuestionDBConnection.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
        JOIN
          (
            SELECT
              question_id, COUNT(follower_id) AS 'followers'
            FROM
              question_follows
            GROUP BY
              question_id
          ) AS follow_count ON questions.id = follow_count.question_id
      ORDER BY
        followers
      LIMIT
        ?
    SQL
    data.map { |datum| Question.new(datum) }
  end
end
