--Логирование действия пользователя
--INSERT INTO [Тип объекта]([Тип объекта]ActionID, [Тип объекта]ID, UserID, ActionTimeStamp) VALUES ([ID действия], [ID каталога], [ID пользователя], NOW());
INSERT INTO NodesLog(NodeActionID, NodeID, UserID, ActionTimeStamp) VALUES ((select NodeActionID from NodeActions where NodeActionName='Создать'),
	(select NodeID from Nodes where NodeName='folder'), (select UserID from Users where LoginWord='user'), NOW());