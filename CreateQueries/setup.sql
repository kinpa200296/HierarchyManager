-- Расширение файла
INSERT INTO FileExtensions(Mask, Description) VALUES ('*.exe','Исполняемый файл Windows');
INSERT INTO FileExtensions(Mask, Description, Icon) VALUES ('*.avi','Видеофайл', 'video.png');
INSERT INTO FileExtensions(Mask, Description) VALUES ('*.mp3','Звуковой файл');
-- Действия над папками
INSERT INTO NodeActions(NodeActionName) VALUES ('Создать');
INSERT INTO NodeActions(NodeActionName) VALUES ('Открыть');
INSERT INTO NodeActions(NodeActionName) VALUES ('Удалить');
INSERT INTO NodeActions(NodeActionName) VALUES ('Переименовать');
-- Действия над файлами
INSERT INTO FileActions(FileActionName) VALUES ('Создать');
INSERT INTO FileActions(FileActionName) VALUES ('Открыть');
INSERT INTO FileActions(FileActionName) VALUES ('Копировать');
INSERT INTO FileActions(FileActionName) VALUES ('Удалить');
INSERT INTO FileActions(FileActionName) VALUES ('Аннигилировать');