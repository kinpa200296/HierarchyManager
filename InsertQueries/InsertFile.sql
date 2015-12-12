--Добавление файла в папку с заданным ID
--INSERT INTO Files(Name, ExtensionID, FileData, IsShared) VALUES ([Имя], [ID расширения], LOAD_FILE([Имя физического файла], [Доступ]);
--INSERT INTO NodeFiles(NodeID, FileID) VALUES ([ID РОдительского каталога], [ID файла]);
INSERT INTO Files VALUES (N'Марсианин(2015)', (select ExtensionID from FileExtensions where Mask='*.avi'), LOAD_FILE('Марсианин(2015).avi'), 0);
INSERT INTO NodeFiles VALUES ((select NodeID from Nodes where NodeName='folder'), (select FileID from Files where Name=N'Марсианин(2015)'));