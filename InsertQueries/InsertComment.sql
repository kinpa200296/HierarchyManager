--Добавление комментария
--INSERT INTO Comments(UserID, FileID, CommentText) VALUES ([ID файла], [ID пользователя],[Текст комментария]);
INSERT INTO Files(Name, ExtensionID, IsShared) VALUES ('Марсианин(2015)', (select ExtensionID from FileExtensions where Mask='*.avi'), 0);
INSERT INTO NodeFiles(NodeID, FileID) VALUES ((select NodeID from Nodes where NodeName='folder'), (select FileID from Files where Name='Марсианин(2015)'));
INSERT INTO Comments(UserID, FileID, CommentText) VALUES ((select UserID from Users where LoginWord='user'), (select FileID from Files where Name='Марсианин(2015)'),
	'Фильм гАвно, мне нипарнавился НИРИАЛИСТИЧНО!!!! Зря потратить свои деньги. Книга лучше!');