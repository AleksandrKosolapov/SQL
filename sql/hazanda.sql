-- Запуск postgres в Docker-контейнере postgres-client
-- psql --host $APP_POSTGRES_HOST -U postgres

-- Получение статистики результатов работы экспертов с расчетом премий за проделанную работу за учетный период:
WITH temp as (SELECT resolved_by_id as expert_id, count(id) as count FROM tickets WHERE resolved_by_id IS NOT NULL GROUP BY resolved_by_id) SELECT name, expert_id, count, round(100*count/(SELECT sum(count) FROM temp), 2) as percent, round(50000*(count/(SELECT sum(count) FROM temp))) as earnings FROM temp JOIN users ON temp.expert_id=users.id ORDER BY count DESC;

-- Получение списка id экспертов, администраторов и юзеров,которые были наиболее активными в чатах тикетов за учетный период:
with t1 as (select author_id, count(author_id) as chat_messages FROM chat_messages GROUP BY author_id) select author_id, type, chat_messages FROM t1 JOIN users ON t1.author_id=users.id ORDER BY chat_messages DESC LIMIT 20;
Бизнес-задача: Анализ диалогов с целью поиска инсайтов по развитию системы чатов, а также выработки правил общения для экспертов. 

-- Получение списка чатов с наибольшим количеством сообщений.
select chat_id, count(chat_id) as count FROM chat_messages GROUP BY chat_id ORDER BY count DESC LIMIT 10;

-- Получение списков самых просматриваемых тикетов, которые просматривали: а) эксперты, б) юзеры.
SELECT id, status, text, visits_count_expert, visits_count_user FROM tickets WHERE visits_count_expert IS NOT NULL ORDER BY visits_count_expert DESC LIMIT 10; 
SELECT id, status, text, visits_count_user, visits_count_expert FROM tickets WHERE visits_count_user IS NOT NULL ORDER BY visits_count_user DESC LIMIT 10; 

-- Получение распределения авторизаций в сервисе через профили соцсетей уникальными пользователям:
SELECT oauth_source, count(oauth_source) FROM users WHERE oauth_source IS NOT NULL GROUP BY oauth_source;
 
-- Получение списка наиболее сложных тикетов, которые протеггировали более чем один эксперт:
ALTER TABLE tickets RENAME COLUMN resoved_by_id TO resolved_by_id;
DROP VIEW ranks, places;
CREATE VIEW places AS
SELECT resolved_by_id as expert_id, count(id) as count FROM tickets WHERE resolved_by_id IS NOT NULL GROUP BY resolved_by_id ORDER BY count DESC;
CREATE VIEW ranks AS
SELECT name, expert_id, count, row_number() over (order by count asc) as place FROM places JOIN users ON places.expert_id=users.id;
with t1 as (SELECT * FROM notices) SELECT ticket_id as ticket, count(type) as count_tag, array_agg(type) as types, array_agg(text) as notices, array_agg(user_id) as experts, round(avg(place),1) as difficulty FROM t1 JOIN ranks ON user_id=expert_id WHERE  type <> 'SOLVED' GROUP BY ticket ORDER BY count_tag DESC, difficulty DESC LIMIT 10;

-- Получение списка почтовых сервисов пользователей.
with tmp as (select substring(email from '@(.*)$'), count(*) from users group by substring(email from '@(.*)$') ORDER by count DESC) select *, round(100*count/(sum(count) over())) as percent FROM tmp LIMIT 10;

-- Получение списка пользователей, создавших больше всего тикетов. 
WITH t1 as (SELECT id as id1, user_id as us1 FROM tickets) SELECT us1 as user, count(id1) FROM t1 JOIN users ON us1=users.id GROUP BY us1 ORDER BY count(id1) DESC LIMIT 20;

-- Получение списка пользователей, не создавших тикет в сервисе.
WITH tmp as (SELECT user_id FROM tickets) SELECT DISTINCT id FROM tmp RIGHT  JOIN users ON user_id=users.id WHERE user_id is null ORDER BY id asc;

-- Получение списка таблиц БД:
SELECT TABLE_NAME, pg_size_pretty(total_size) AS total_size
FROM (SELECT TABLE_NAME, pg_total_relation_size(TABLE_NAME) AS total_size
FROM (SELECT ('' || table_schema || '.' || TABLE_NAME || '') AS TABLE_NAME FROM information_schema.tables ) AS all_tables ORDER BY total_size DESC) AS ps LIMIT 20;

-- Получение списка тикетов с одинаковым текстом:
DROP VIEW dublicates;
CREATE VIEW dublicates as
SELECT (tickets.text)::text, count(*) FROM tickets GROUP BY tickets.text HAVING count(*) > 1 ORDER BY count(*) DESC;
SELECT * FROM dublicates LIMIT 10;