--Добавление оценки
--INSERT INTO Ratings(UserID, FileID, Value) VALUES ([ID пользователя], [ID файла], [Оценка (1-5)]);
INSERT INTO Ratings(UserID, FileID, Value) VALUES ((select UserID from Users where LoginWord='user'), (select FileID from Files where Name='Марсианин(2015)'), 1);