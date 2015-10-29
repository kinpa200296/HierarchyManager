-- Добавление корневой папки
-- INSERT INTO Nodes(NodeName, UserID, IsShared) VALUES ([Название], [ID пользователя], [Доступ]);
INSERT INTO Nodes(NodeName, UserID, IsShared) VALUES ('root', (select UserID from Users where LoginWord='user'), 0);
UPDATE Users SET RootNodeID=(select NodeID from Nodes where NodeName='root') where LoginWord='user';