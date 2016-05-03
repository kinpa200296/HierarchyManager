drop function Login;
drop function GetComments;
drop function GetDirContent;
drop procedure MakeComment;
drop procedure InsertEdge;
drop procedure InsertFile;
drop type rowsGetComments;
drop type rowGetComments;
drop type rowsGetDirContent;
drop type rowGetDirContent;


drop trigger Edges_TRG;
drop sequence Edges_SEQ;
drop table Edges;

drop trigger NodesLog_TRG;
drop sequence NodesLog_SEQ;
drop table NodesLog;

drop trigger NodeFiles_INS_TRG;
drop trigger NodeFiles_DEL_TRG;
drop table NodeFiles;

drop trigger FilesLog_TRG;
drop sequence FilesLog_SEQ;
drop table FilesLog;

drop table Ratings;

drop trigger Comments_TRG;
drop sequence Comments_SEQ;
drop table Comments;

drop trigger FileActions_TRG;
drop trigger FileActions_DEL_TRG;
drop sequence FileActions_SEQ;
drop table FileActions;

drop trigger Files_TRG;
drop trigger Files_DEL_TRG;
drop sequence Files_SEQ;
drop table Files;

drop trigger FileExt_TRG;
drop sequence FileExt_SEQ;
drop table FileExtensions;

drop trigger NodeActions_TRG;
drop trigger NodeActions_DEL_TRG;
drop sequence NodeActions_SEQ;
drop table NodeActions;

drop trigger Nodes_TRG;
drop trigger Nodes_INS_TRG;
drop trigger Nodes_UPD_TRG;
drop trigger Nodes_DEL_TRG;
drop trigger Nodes_DEL2_TRG;
drop sequence Nodes_SEQ;
drop table Nodes;

drop trigger Users_TRG;
drop trigger Users_DEL_TRG;
drop sequence Users_SEQ;
drop table Users;