-- Добваление некорневой папки
-- INSERT INTO Nodes VALUES ([Название], [ID пользователя], [Доступ]);
-- INSERT INTO Edges VALUES ([ID родительского каталога], [ID дочернего каталога], [ID пользователя]);
INSERT INTO Nodes(NodeName, UserID, IsShared) VALUES ('folder', (select UserID from Users where LoginWord='user'), 0);
INSERT INTO Edges(ChildID, ParentID, UserID) VALUES ((select NodeID from Nodes where NodeName='root'), (select NodeID from Nodes where NodeName='folder'), (select UserID from Users where LoginWord='user'));