class User < ModelBase
  attr_accessor :fname, :lname

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.table_name
    'users'
  end

  def self.find_by_name(fname, lname)
    data = QuestionDBConnection.instance.execute(<<-SQL,fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    User.new(data.first)
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    data = QuestionDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        AVG(likes_for_question) AS average_karma
      FROM
        questions
        JOIN
          (
            SELECT
              question_id, COUNT(user_id) AS likes_for_question
            FROM
              question_likes
            GROUP BY
              question_id
          ) AS like_count ON questions.id = like_count.question_id
      WHERE
        questions.author_id = ?
    SQL
    data.first['average_karma']
  end
end
