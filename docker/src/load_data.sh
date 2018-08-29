#/bin/sh

psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "DROP TABLE IF EXISTS tickets"
psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "DROP TABLE IF EXISTS users"
psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "DROP TABLE IF EXISTS chat"
psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "DROP TABLE IF EXISTS chat_messages"
psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "DROP TABLE IF EXISTS notices"

echo "Загружаем tickets.csv..."
psql --host $APP_POSTGRES_HOST -U postgres -c '
  CREATE TABLE tickets (
	id bigint,
	has_attachment boolean,
	status varchar (255),
	text varchar (5000),
	link varchar (255),
	user_id bigint,
	resoved_by_id bigint,
	target_id bigint,
	visits_count_admin int,
	visits_count_expert int,
	visits_count_user int
  );'

psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "\\copy tickets FROM '/data/tickets.csv' DELIMITER ',' CSV HEADER"


echo "Загружаем users.csv..."
psql --host $APP_POSTGRES_HOST -U postgres -c '
  CREATE TABLE users (
	id bigint,
	email varchar (255),
	login varchar (255),
	mailing_enable boolean,
	name varchar (255),
	status varchar (255),
	type varchar (255),
	oauth_source varchar (255)
  );'

psql --host $APP_POSTGRES_HOST -U postgres -c \
    "\\copy users FROM '/data/users.csv' DELIMITER ',' CSV HEADER"


echo "Загружаем chat.csv..."
psql --host $APP_POSTGRES_HOST -U postgres -c '
  CREATE TABLE chat (
	id bigint,
	target_id bigint,
	ticket_id bigint
  );'

psql --host $APP_POSTGRES_HOST -U postgres -c \
    "\\copy chat FROM '/data/chat.csv' DELIMITER ',' CSV HEADER"


echo "Загружаем chat_messages.csv..."
psql --host $APP_POSTGRES_HOST -U postgres -c '
  CREATE TABLE chat_messages (
id bigint,
text varchar (5000),
author_id bigint,
chat_id bigint
  );'

psql --host $APP_POSTGRES_HOST -U postgres -c \
    "\\copy chat_messages FROM '/data/chat_messages.csv' DELIMITER ',' CSV HEADER"


echo "Загружаем notices.csv..."
psql --host $APP_POSTGRES_HOST -U postgres -c '
  CREATE TABLE notices (
id bigint,
ticket_id bigint,
related_type varchar (255),
text varchar (5000),
type varchar (255),
user_id	bigint
  );'

psql --host $APP_POSTGRES_HOST -U postgres -c \
    "\\copy notices FROM '/data/notices.csv' DELIMITER ',' CSV HEADER"