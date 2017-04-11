DROP TABLE IF EXISTS users;

CREATE TABLE users(
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions(
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  follower_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (follower_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  author_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Monte', 'Jiran'),
  ('Chris', 'Cankov'),
  ('Luke', 'Wessink');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Halp', 'Where is bathroom?', (SELECT id FROM users WHERE fname = 'Monte')),
  ('Error', 'Stack overflow', (SELECT id FROM users WHERE fname = 'Chris')),
  ('Wipe down your desks', 'This is a reminder you MUST wipe down your desks EACH DAY', (SELECT id FROM users WHERE fname = 'Luke'));

INSERT INTO
  question_follows (question_id, follower_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'Halp'), (SELECT id FROM users WHERE fname = 'Chris')),
  ((SELECT id FROM questions WHERE title = 'Error'), (SELECT id FROM users WHERE fname = 'Monte'));

INSERT INTO
  replies (question_id, parent_id, author_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = 'Halp'), NULL, (SELECT id FROM users WHERE fname = 'Luke'), 'Around the corner'),
  ((SELECT id FROM questions WHERE title = 'Halp'), (SELECT id FROM replies WHERE body = 'Around the corner'), (SELECT id FROM users WHERE fname = 'Monte'), 'Thanks');

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Chris'), (SELECT id FROM questions WHERE title = 'Halp')),
  ((SELECT id FROM users WHERE fname = 'Monte'), (SELECT id FROM questions WHERE title = 'Halp')),
  ((SELECT id FROM users WHERE fname = 'Luke'), (SELECT id FROM questions WHERE title = 'Halp'));
