--просмотр пользователей
select UserID, LoginWord from users;

SELECT UserId from users where LoginWord=@Login and PassPhrase=@pass

--просмотр корневых каталогов пользователя
select NodeID, NodeName
from Nodes left join Edges on Nodes.NodeID=Edges.ChildID
where Nodes.UserID=1 and Edges.ParentID is NULL;

--просмотр подкаталогов  и файлов конкретного каталога
select  Nodes.NodeID as ID, Nodes.NodeName as Name, 'folder' as Type
from Nodes left join Edges on Nodes.NodeID=Edges.ChildID
where Edges.ParentID=2

union

select  Files.FileID as ID, Files.Name as Name, 'file' as Type
from Files left join NodeFiles on NodeFiles.FileID=Files.FileID
where NodeFiles.NodeID=2
order by 3 desc,2;

--просмотр комментариев к файлу
select Comments.commentID, Users.LoginWord, Comments.CommentText
from Comments
left join Users on Comments.UserID=Users.UserID
where Comments.FileID=1;

--просмотр общедоуступных файлов в каталоге пользователя с доп. информацией
select Files.FileID, Files.Name, Ratings.Value, FileExtensions.Extension
from Files
left join NodeFiles on NodeFiles.FileID=Files.FileID
left join Ratings on Ratings.FileID=Files.FileID
left join FileExtensions on Files.ExtensionID=FileExtensions.ExtensionID
where NodeFiles.NodeID=2;

--просмотр логов действий пользователя
select Users.LoginWord, NodeActions.NodeActionName, Nodes.NodeName, NodesLog.ActionTimeStamp from NodesLog
left join NodeActions on NodesLog.NodeActionID=NodeActions.NodeActionID
left join Nodes on NodesLog.NodeID=Nodes.NodeID
left join Users on NodesLog.UserID=Users.UserID
where NodesLog.UserID = 1 order by NodesLog.ActionTimeStamp;