require 'sqlite3'
require 'singleton'
require_relative 'model_base.rb'
require_relative 'users.rb'
require_relative 'question_follows.rb'
require_relative 'replies.rb'
require_relative 'question_likes.rb'

class QuestionDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Question < ModelBase
  attr_accessor :title, :body, :author_id

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def self.table_name
    'questions'
  end

  def self.find_by_author_id(author_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    data.map{|datum| Question.new(datum)}
  end

  def self.most_likes(n)
    QuestionLike.most_liked_questions(n)
  end

  def author
    User.find_by_id(@author_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end
end
