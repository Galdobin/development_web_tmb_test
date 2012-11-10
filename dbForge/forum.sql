-- Скрипт сгенерирован Devart dbForge Studio for MySQL, Версия 5.0.97.1
-- Домашняя страница продукта: http://www.devart.com/ru/dbforge/mysql/studio
-- Дата скрипта: 10.11.2012 20:35:08
-- Версия сервера: 5.5.27
-- Версия клиента: 4.1

-- 
-- Отключение внешних ключей
-- 
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

-- 
-- Установка кодировки, с использованием которой клиент будет посылать запросы на сервер
--
SET NAMES 'utf8';

-- 
-- Установка базы данных по умолчанию
--
USE forum;

--
-- Описание для таблицы comments
--
DROP TABLE IF EXISTS comments;
CREATE TABLE comments (
  id INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  topic INT(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'topic.id (Тема обсуждения)',
  author INT(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'users.id (Автор комментария)',
  content TEXT CHARACTER SET ujis COLLATE ujis_japanese_ci NOT NULL COMMENT 'Содержание комментария',
  `date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата добавления',
  PRIMARY KEY (id)
)
ENGINE = MYISAM
AUTO_INCREMENT = 51
AVG_ROW_LENGTH = 76
CHARACTER SET utf8
COLLATE utf8_general_ci
COMMENT = 'Комментарии';

--
-- Описание для таблицы rb_rights
--
DROP TABLE IF EXISTS rb_rights;
CREATE TABLE rb_rights (
  id INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  name TEXT CHARACTER SET ujis COLLATE ujis_japanese_ci NOT NULL,
  PRIMARY KEY (id)
)
ENGINE = MYISAM
AUTO_INCREMENT = 3
AVG_ROW_LENGTH = 36
CHARACTER SET utf8
COLLATE utf8_general_ci
COMMENT = 'Права пользователя';

--
-- Описание для таблицы rb_status
--
DROP TABLE IF EXISTS rb_status;
CREATE TABLE rb_status (
  id INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  name TEXT CHARACTER SET ujis COLLATE ujis_japanese_ci NOT NULL,
  PRIMARY KEY (id)
)
ENGINE = MYISAM
AUTO_INCREMENT = 4
AVG_ROW_LENGTH = 48
CHARACTER SET utf8
COLLATE utf8_general_ci
COMMENT = 'Состояние пользователя';

--
-- Описание для таблицы rubrics
--
DROP TABLE IF EXISTS rubrics;
CREATE TABLE rubrics (
  id INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  parent INT(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'rubrics.id (Родительская рубрика)',
  name TEXT CHARACTER SET ujis COLLATE ujis_japanese_ci NOT NULL COMMENT 'Название',
  PRIMARY KEY (id)
)
ENGINE = MYISAM
AUTO_INCREMENT = 31
AVG_ROW_LENGTH = 30
CHARACTER SET utf8
COLLATE utf8_general_ci
COMMENT = 'Рубрики';

--
-- Описание для таблицы topic
--
DROP TABLE IF EXISTS topic;
CREATE TABLE topic (
  id INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  rubric INT(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'rubrics.id (Рубрика)',
  name TEXT CHARACTER SET ujis COLLATE ujis_japanese_ci NOT NULL COMMENT 'Название',
  author INT(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'users.id (Автор темы)',
  `date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата создания темы',
  PRIMARY KEY (id)
)
ENGINE = MYISAM
AUTO_INCREMENT = 11
AVG_ROW_LENGTH = 64
CHARACTER SET utf8
COLLATE utf8_general_ci
COMMENT = 'Темы';

--
-- Описание для таблицы users
--
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  name TEXT CHARACTER SET ujis COLLATE ujis_japanese_ci NOT NULL COMMENT 'Имя',
  mail TEXT CHARACTER SET ujis COLLATE ujis_japanese_ci NOT NULL COMMENT 'Е-мейл (логин)',
  pass TEXT CHARACTER SET ujis COLLATE ujis_japanese_ci NOT NULL COMMENT 'Пароль',
  rights INT(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'rb_rights.id (Права)',
  status INT(11) NOT NULL DEFAULT 0 COMMENT 'rb_status.id (Статус)',
  `date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата регистрации',
  PRIMARY KEY (id)
)
ENGINE = MYISAM
AUTO_INCREMENT = 21
AVG_ROW_LENGTH = 104
CHARACTER SET utf8
COLLATE utf8_general_ci
COMMENT = 'Пользователи';

DELIMITER $$

--
-- Описание для процедуры all_topic
--
DROP PROCEDURE IF EXISTS all_topic$$
CREATE PROCEDURE all_topic(IN _page INT)
  SQL SECURITY INVOKER
BEGIN
	DECLARE rop INT DEFAULT 4;

	SET @pos = 0;
	SELECT
		abc.pos
	, topic.name
	, rubrics.name AS rubric
	, users.name AS username
		FROM
			(
			SELECT
				(@pos := @pos + 1) AS pos
			, topic.id AS ID
				FROM
					topic
				ORDER BY
					topic.name) AS abc
		JOIN topic
		ON topic.id = abc.id
		JOIN rubrics
		ON rubrics.id = topic.rubric
		JOIN users
		ON users.id = topic.author
		WHERE
			abc.pos BETWEEN (_page - 1) * rop + 1 AND _page * rop;

	SELECT
		ceiling(count(topic.id) / rop) AS cnt
		FROM
			topic;
END
$$

--
-- Описание для процедуры rubric
--
DROP PROCEDURE IF EXISTS rubric$$
CREATE PROCEDURE rubric(IN _id INT)
  SQL SECURITY INVOKER
BEGIN
	IF _id = 0 THEN
		SELECT # 0 Информация о корне форума
					 -1 AS parent
				 , 'ФОРУМ' AS name;
	ELSE
		SELECT # 0 Информация о текущей рубрике
					 rubrics.parent
				 , rubrics.name
			FROM rubrics
			WHERE rubrics.id = _id;
	END IF;
	SELECT # 1 Список дочерних рубрик
				 rubrics.id
			 , rubrics.name
		FROM rubrics
		WHERE rubrics.parent = _id;

	SELECT # 2 Список тем
				 topic.id
			 , topic.name
			 , topic.date
			 , users.name AS author_name
		FROM topic
		JOIN users
		ON users.id = topic.author
		WHERE topic.rubric = _id;
END
$$

--
-- Описание для процедуры test
--
DROP PROCEDURE IF EXISTS test$$
CREATE PROCEDURE test(IN _param INT)
  SQL SECURITY INVOKER
BEGIN
    SELECT
        *
    FROM
        comments;
    SELECT
        *
    FROM
        rubrics;
END
$$

DELIMITER ;

-- 
-- Вывод данных для таблицы comments
--
INSERT INTO comments VALUES 
  (1, 1, 1, 'Ах, какое кино раньше снимали!...', '2012-02-16 10:36:26'),
  (2, 1, 2, 'Да...', '2012-02-16 10:36:53'),
  (3, 2, 2, 'За Спартак', '2012-02-16 10:37:12'),
  (4, 2, 1, 'За московский?', '2012-02-16 10:37:36'),
  (5, 2, 2, 'Нет, за тамбовский.', '2012-02-16 10:37:57'),
  (6, 1, 2, 'Сейчас тоже снимают)', '2012-02-16 14:17:33'),
  (7, 3, 3, 'Мне не понравился', '2012-02-16 14:58:50'),
  (8, 3, 7, 'Да действительно не очень', '2012-02-16 14:59:19'),
  (9, 10, 14, 'Конечно выйдет!', '2012-02-16 15:00:06'),
  (10, 6, 9, 'Наши яблоки намного вкуснее иностранных и полезнее', '2012-02-16 15:01:54'),
  (11, 1, 10, 'Снимают то снимают но уже не так', '2012-02-16 15:06:18'),
  (12, 6, 3, 'Согласен полнотью', '2012-02-16 15:07:21'),
  (13, 2, 7, 'Да зенит круче!', '2012-02-16 15:07:46'),
  (14, 7, 9, 'Макаревич еще дает дрозда молодежи!', '2012-02-16 15:08:40'),
  (15, 9, 11, 'Timo Bol', '2012-02-16 15:09:28'),
  (16, 8, 12, 'А правда что он голым на концерт вышел?', '2012-02-16 15:10:15'),
  (17, 9, 14, 'Он ж проиграл в финале! ', '2012-02-16 15:11:37'),
  (18, 8, 7, 'Ага! вся группа вышла голяком!', '2012-02-16 15:12:09'),
  (19, 6, 17, 'А есть ли разница?', '2012-02-16 15:13:05'),
  (20, 9, 11, 'А кто тогда?', '2012-02-16 15:13:42'),
  (21, 8, 18, 'Позорище!', '2012-02-16 15:14:17'),
  (22, 2, 1, 'да ЦСКА обыграет обоих!', '2012-02-16 15:16:11'),
  (23, 6, 10, 'Конечно есть! Наши намного полезнее и вкуснее)', '2012-02-16 15:16:50'),
  (24, 9, 14, 'Самсонов наверно1 сам не знаю может кто подскажет?', '2012-02-16 15:17:44'),
  (25, 4, 5, 'А что там происходило?', '2012-02-16 15:18:31'),
  (26, 5, 4, 'Очень красивые фотографии', '2012-02-16 15:19:43'),
  (27, 7, 14, 'Да ну он петь не умеет', '2012-02-16 15:20:49'),
  (28, 4, 8, 'Начиналось всё мирно а закончилось массовым мордобоем!', '2012-02-16 15:21:38'),
  (29, 7, 7, 'Он петь не умеет?? А кто ж тогда умеет?!', '2012-02-16 15:22:24'),
  (30, 4, 8, 'А ты то там что забыла?', '2012-02-16 15:23:06'),
  (31, 8, 19, 'А по моему как хочет так пусть и ведет себя он ж никого не призывает так делать)', '2012-02-16 15:24:17'),
  (32, 2, 13, 'А спартак вообще играть не умеет', '2012-02-16 15:25:05'),
  (33, 4, 8, 'Там ж не только я была!', '2012-02-16 15:25:49'),
  (34, 10, 2, 'Да не не выйдет Брюс уже не тот!', '2012-02-16 15:26:27'),
  (35, 7, 14, 'Вот Хворостовский умеет!', '2012-02-16 15:27:14'),
  (36, 6, 1, 'Только наши яблоки не достать на прилавках(', '2012-02-16 15:28:04'),
  (37, 10, 4, 'Да ладно тебе! Сильвестру Сталоне вон скалько а он всё бегает', '2012-02-16 15:29:00'),
  (38, 2, 2, 'Играет играет Спартак правда не оч хорошо!', '2012-02-16 15:30:30'),
  (39, 5, 10, 'А ночные фотографии есть?', '2012-02-16 15:31:09'),
  (40, 7, 3, 'Не сравнивай оперное пение с роком!', '2012-02-16 15:31:53'),
  (41, 4, 11, 'А до драки что нибудь говорили?', '2012-02-16 15:33:14'),
  (42, 3, 15, 'Мне одному только понравилось?', '2012-02-16 15:34:18'),
  (43, 4, 14, 'Об успеваемости учеников и о поступлении их в ВУЗы', '2012-02-16 15:36:02'),
  (44, 8, 4, 'Он музыку то думает сочинять или всё голяком тусоваться будет?', '2012-02-16 15:36:55'),
  (45, 4, 20, 'Драка интересней!', '2012-02-16 15:37:27'),
  (46, 9, 3, 'Да Самсонов стал чемпионом!', '2012-02-16 15:38:24'),
  (47, 9, 14, 'Спасибо', '2012-02-16 15:38:59'),
  (48, 1, 16, 'А я не смотрела( киньте ссылку пожалуйста', '2012-02-16 15:40:21'),
  (49, 2, 12, 'Всё таки зенит лучше!', '2012-02-16 15:41:01'),
  (50, 3, 14, 'И мне тоже', '2012-02-16 15:41:51');

-- 
-- Вывод данных для таблицы rb_rights
--
INSERT INTO rb_rights VALUES 
  (1, 'Пользователь'),
  (2, 'Администратор');

-- 
-- Вывод данных для таблицы rb_status
--
INSERT INTO rb_status VALUES 
  (1, 'Нормальный'),
  (2, 'Ожидает подтверждения регистрации'),
  (3, 'Заблокирован');

-- 
-- Вывод данных для таблицы rubrics
--
INSERT INTO rubrics VALUES 
  (1, 0, 'Кино'),
  (2, 0, 'Спорт'),
  (3, 0, 'Музыка'),
  (4, 1, 'Боевики'),
  (5, 1, 'Комедии'),
  (6, 1, 'Документальное'),
  (7, 2, 'Футбол'),
  (8, 2, 'Хоккей'),
  (9, 2, 'Бокс'),
  (10, 3, 'Рок'),
  (11, 3, 'Попса'),
  (12, 3, 'Классика'),
  (13, 12, 'Моцарт'),
  (14, 12, 'Бетховен'),
  (15, 12, 'Чайковский'),
  (16, 0, 'Общественная жизнь города'),
  (17, 16, 'Тамбов'),
  (18, 16, 'Котовск'),
  (19, 16, 'Рассказово'),
  (20, 16, 'Мичуринск'),
  (21, 2, 'Настольный теннис'),
  (22, 1, 'Драмы'),
  (23, 1, 'Трагедии'),
  (24, 10, 'Король и Шут'),
  (25, 10, 'Rammstein'),
  (26, 10, 'DDT'),
  (27, 10, 'Машина времени'),
  (28, 3, 'СКА'),
  (29, 28, 'Ленинград'),
  (30, 4, 'Крепкий орешек');

-- 
-- Вывод данных для таблицы topic
--
INSERT INTO topic VALUES 
  (1, 6, 'Ленин в октябре', 2, '2012-02-16 10:34:37'),
  (2, 7, 'Кто за кого фанатеет', 1, '2012-02-16 10:35:43'),
  (3, 13, 'Филармонический концерт памяти великого музыканта', 6, '2012-02-16 14:33:06'),
  (4, 17, 'Митинг в 5 школе', 3, '2012-02-16 14:35:09'),
  (5, 18, 'Фотографии', 10, '2012-02-16 14:36:23'),
  (6, 20, 'О пользе отечественных яблок', 14, '2012-02-16 14:53:03'),
  (7, 27, 'Концерт в кремле', 12, '2012-02-16 14:54:22'),
  (8, 29, 'Новые выходки шнура', 7, '2012-02-16 14:55:19'),
  (9, 21, 'Кто стал чемпионом мира?', 5, '2012-02-16 14:56:29'),
  (10, 30, 'Выйдет ли новая часть?', 13, '2012-02-16 14:57:36');

-- 
-- Вывод данных для таблицы users
--
INSERT INTO users VALUES 
  (1, 'Иван Иванов', 'ivan@mail.com', 'a722c63db8ec8625af6cf71cb8c2d939', 2, 1, '2012-02-16 10:25:14'),
  (2, 'Петр Петров', 'petrov@mail.com', 'c1572d05424d0ecb2a65ec6a82aeacbf', 1, 1, '2012-02-16 10:27:34'),
  (3, 'Алексей Алексеев', 'alex@mail.com', '3afc79b597f88a72528e864cf81856d2', 2, 1, '2012-02-16 14:07:52'),
  (4, 'Антон Антонов', 'antonchik@mail.ru', 'fc2921d9057ac44e549efaf0048b2512', 1, 2, '2012-02-16 14:20:24'),
  (5, 'Сергей Сажнев', 'serg@mail.ru', 'd35f6fa9a79434bcd17f8049714ebfcb', 1, 1, '2012-02-16 14:22:34'),
  (6, 'Артем Острожков', 'artemka@gmail.com', 'e9568c9ea43ab05188410a7cf85f9f5e', 1, 2, '2012-02-16 14:24:09'),
  (7, 'Сергей Малютин', 'sergemalyutin@gmail.com', '8c96c3884a827355aed2c0f744594a52', 2, 1, '2012-02-16 14:25:20'),
  (8, 'Елена Комиссарова', 'lenka@mail.ru', 'ccd3cd18225730c5edfc69f964b9d7b3', 2, 1, '2012-02-16 14:27:09'),
  (9, 'Юля Харитонова', 'yula@gmail.com', 'c28cce9cbd2daf76f10eb54478bb0454', 1, 3, '2012-02-16 14:28:14'),
  (10, 'Наталия Журавлева', 'tashka@mail.ru', 'a3224611fd03510682690769d0195d66', 2, 2, '2012-02-16 14:30:30'),
  (11, 'Андрей Пробкин', 'probka@list.ru', '0102812fbd5f73aa18aa0bae2cd8f79f', 1, 3, '2012-02-16 14:44:14'),
  (12, 'Ксения Коновалова', 'ksyusha@gmail.com', '0bd0fe6372c64e09c4ae81e056a9dbda', 1, 2, '2012-02-16 14:45:33'),
  (13, 'Валентин Михеев', 'mix.val@mail.ru', 'c868bff94e54b8eddbdbce22159c0299', 1, 1, '2012-02-16 14:47:08'),
  (14, 'Татьяна Самойлова', 'samoilovatanya@yandex.ru', 'd1f38b569c772ebb8fa464e1a90c5a00', 1, 2, '2012-02-16 14:48:52'),
  (15, 'Артур Смолянинов', 'smol@mail.ru', 'b279786ec5a7ed00dbe4d3fe1516c121', 2, 1, '2012-02-16 14:50:22'),
  (16, 'Екатерина Ивановская', 'ivanovskaya@mail.ru', '66c99bf933f5e6bf3bf2052d66577ca8', 1, 1, '2012-02-16 15:45:10'),
  (17, 'Алексей Алексеев', 'leksey@gmail.com', '6c2a5c9ead1d7d6ba86c8764d5cad395', 1, 2, '2012-02-16 15:46:18'),
  (18, 'Володя Картошкин', 'kartoshka@yandex.ru', '64152ab7368fc7ca6b3ef6b71e330b86', 1, 1, '2012-02-16 15:47:32'),
  (19, 'Михаил Колобков', 'kolobok@mail.ru', '1f61b744f2c9e8f49ae4c4965f39963f', 2, 1, '2012-02-16 15:48:44'),
  (20, 'Николай Ивановский', 'kolya@list.ru', '90bfa11df19a9b9d429ccfa6997104df', 1, 3, '2012-02-16 15:49:35');

-- 
-- Включение внешних ключей
-- 
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;