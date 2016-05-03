-----------------------------------------------------------------------
---------------------   User operations section   ---------------------
------------------------------------------------------------------Users
CREATE TABLE Users
(
	UserID		NUMBER PRIMARY KEY NOT NULL,
	LoginWord	VARCHAR2(50) NOT NULL,
	PassPhrase	VARCHAR2(50) NOT NULL,
	FirstName	VARCHAR2(50),
	LastName	VARCHAR2(50)
);

create sequence Users_SEQ;

create or replace trigger Users_TRG
before insert on Users
for each row
begin
  :NEW.UserID := Users_SEQ.nextval;
end Users_TRG;

create or replace trigger Users_DEL_TRG
before delete on Users
for each row
begin
  delete from Comments where Comments.UserID = :OLD.UserID;
  delete from Ratings where Ratings.UserID = :OLD.UserID;
  --delete from FilesLog where FilesLog.UserID = :OLD.UserID;
  delete from Edges where Edges.UserID = :OLD.UserID;
  --delete from NodesLog where NodesLog.UserID = :OLD.UserID;
  delete from Nodes where Nodes.UserID = :OLD.UserID;
end Users_DEL_TRG;

-----------------------------------------------------------------------
--------------------   Folder operations section   --------------------
------------------------------------------------------------------Nodes
CREATE TABLE Nodes
(
	NodeID		NUMBER PRIMARY KEY NOT NULL,
	NodeName	VARCHAR2(50) NOT NULL,
	UserID		NUMBER NOT NULL,
	IsShared	NUMBER NOT NULL,
  CONSTRAINT NodeUser_FK FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

create sequence Nodes_SEQ;

create or replace trigger Nodes_TRG
before insert on Nodes
for each row
begin
  :NEW.NodeID := Nodes_SEQ.nextval;
end Nodes_TRG;

create or replace trigger Nodes_INS_TRG
after insert on Nodes
for each row
declare
  actionId number;
begin
  select first_value(NodeActions.NodeActionID) into actionId from NodeActions
    where NodeActions.NodeActionName = 'Создать';
	insert into NodesLog(NodeActionID, NodeID, UserID, ActionTimeStamp)
	  values (actionId, :NEW.NodeID, :NEW.UserID, sysdate);
end Nodes_INS_TRG;

create or replace trigger Nodes_UPD_TRG
after update on Nodes
for each row
declare
  actionId number;
begin
  if :OLD.NodeName <> :NEW.NodeName
    then
      select first_value(NodeActions.NodeActionID) into actionId from NodeActions
        where NodeActions.NodeActionName = 'Переименовать';
      insert into NodesLog(NodeActionID, NodeID, UserID, ActionTimeStamp)
      values (actionId, :OLD.NodeID, :OLD.UserID, sysdate);
    end if;
end Nodes_UPD_TRG;

create or replace trigger Nodes_DEL_TRG
before delete on Nodes
for each row
begin
  delete from NodeFiles where NodeFiles.NodeID = :OLD.NodeID;
  --delete from NodesLog where NodesLog.NodeID = :OLD.NodeID;
  delete from Edges where Edges.ChildID = :OLD.NodeID or Edges.ParentID = :OLD.NodeID;
end Nodes_DEL_TRG;

create or replace trigger Nodes_DEL2_TRG
after delete on Nodes
for each row
begin
	insert into NodesLog(NodeActionID, NodeID, UserID, ActionTimeStamp)
	values ((select NodeActions.NodeActionID from NodeActions where NodeActions.NodeActionName = 'Удалить'),
					:OLD.NodeID, :OLD.UserID, sysdate);
end Nodes_DEL2_TRG;

------------------------------------------------------------------Edges
CREATE TABLE Edges
(
	EdgeID		NUMBER PRIMARY KEY NOT NULL,
	ChildID		NUMBER NOT NULL,
	ParentID	NUMBER NOT NULL,
	UserID		NUMBER NOT NULL,
	CONSTRAINT ChildNode_FK FOREIGN KEY (ChildID) REFERENCES Nodes(NodeID),
	CONSTRAINT ParentNode_FK FOREIGN KEY (ParentID) REFERENCES Nodes(NodeID),
	CONSTRAINT UserEdge_FK FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

create sequence Edges_SEQ;

create or replace trigger Edges_TRG
before insert on Edges
for each row
begin
  :NEW.EdgeID := Edges_SEQ.nextval;
end Edges_TRG;

------------------------------------------------------------NodeActions
create table NodeActions
(
  NodeActionID NUMBER PRIMARY KEY NOT NULL,
  NodeActionName VARCHAR2(50) NOT NULL
);

create sequence NodeActions_SEQ;

create or replace trigger NodeActions_TRG
before insert on NodeActions
for each row
begin
	:NEW.NodeActionID := NodeActions_SEQ.nextval;
end NodeActions_TRG;

create or replace trigger NodeActions_DEL_TRG
before delete on NodeActions
for each row
begin
  delete from NodesLog where NodesLog.NodeActionId = :OLD.NodeActionID;
end NodeActions_DEL_TRG;

---------------------------------------------------------------NodesLog
CREATE TABLE NodesLog
(
	NodesLogID		NUMBER PRIMARY KEY NOT NULL,
	NodeActionID	NUMBER NOT NULL,
	NodeID			NUMBER NOT NULL,
	UserID			NUMBER NOT NULL,
	ActionTimeStamp	DATE NOT NULL,
	CONSTRAINT NodeAction_FK FOREIGN KEY (NodeActionID) REFERENCES NodeActions(NodeActionID)
	--CONSTRAINT NodeLog_FK FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID),
	--CONSTRAINT UserNodeLog_FK FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

create sequence NodesLog_SEQ;

create or replace trigger NodesLog_TRG
before insert on NodesLog
for each row
begin
  :NEW.NodesLogID := NodesLog_SEQ.nextval;
end NodesLog_TRG;

-----------------------------------------------------------------------
---------------------   File operations section   ---------------------
---------------------------------------------------------FileExtensions
CREATE TABLE FileExtensions
(
	ExtensionID	NUMBER PRIMARY KEY NOT NULL,
	Mask		VARCHAR2(24) NOT NULL,
	Description	VARCHAR2(160) NOT NULL,
  Icon        VARCHAR2(50)
);

create sequence FileExt_SEQ;

create or replace trigger FileExt_TRG
before insert on FileExtensions
for each row
begin
  :NEW.ExtensionID := FileExt_SEQ.nextval;
end FileExt_TRG;

create or replace trigger FileExt_DEL_TRG
before delete on FileExtensions
for each row
begin
  update Files set Files.ExtensionID = NULL
    where Files.ExtensionID = :OLD.ExtensionID;
end FileExt_DEL_TRG;

------------------------------------------------------------------Files
CREATE TABLE Files
(
	FileID		NUMBER PRIMARY KEY NOT NULL,
	Name		VARCHAR2(50) NOT NULL,
	ExtensionID NUMBER,
	FileData	BLOB,
	IsShared	NUMBER NOT NULL,
	CONSTRAINT Extension_FK FOREIGN KEY (ExtensionID) REFERENCES FileExtensions(ExtensionID)
);

create sequence Files_SEQ;

create or replace trigger Files_TRG
before insert on Files
for each row
begin
  :NEW.FileID := Files_SEQ.nextval;
end Files_TRG;

create or replace trigger Files_DEL_TRG
before delete on Files
for each row
begin
  delete from Comments where Comments.FileID = :OLD.FileID;
  delete from Ratings where Ratings.FileID = :OLD.FileID;
  --delete from FilesLog where FilesLog.FileID = :OLD.FileID;
  delete from NodeFiles where NodeFiles.FileID = :Old.FileID;
end Files_DEL_TRG;

--------------------------------------------------------------NodeFiles
CREATE TABLE NodeFiles
(
	NodeID	NUMBER NOT NULL,
	FileID	NUMBER NOT NULL,
	PRIMARY KEY (NodeID, FileID),
	CONSTRAINT Node_FK FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID),
	CONSTRAINT File_FK FOREIGN KEY (FileID) REFERENCES Files(FileID)
);

create or replace trigger NodeFiles_INS_TRG
after insert on NodeFiles
for each row
declare
  actionId number;
  userId number;
  cnt number := 0;
begin
  select first_value(FileActions.FileActionID) from FileActions
    where FileActions.FileActionName = 'Создать';
  select Nodes.UserID into userId from Nodes
    where Nodes.NodeID = :NEW.NodeID;
  select count(NodeFiles.FileID) into cnt from NodeFiles
    where :NEW.FileID = NodeFiles.FileID;
  if cnt = 1
    then
      select first_value(FileActions.FileActionID) from FileActions
        where FileActions.FileActionName = 'Создать';
    else
      select first_value(FileActions.FileActionID) from FileActions
        where FileActions.FileActionName = 'Копировать';
    end if;
  insert into FilesLog(FileActionID, FileID, UserID, ActionTimeStamp)
	  values (actionId, :NEW.FileID, userId, sysdate);
end NodeFiles_INS_TRG;

create or replace trigger NodeFiles_DEL_TRG
after delete on NodeFiles
for each row
declare
  actionId number;
  userId number;
  cnt number := 0;
begin
  select first_value(FileActions.FileActionID) from FileActions
    where FileActions.FileActionName = 'Удалить';
  select Nodes.UserID into userId from Nodes
    where Nodes.NodeID = :OLD.NodeID;
	insert into FilesLog(FileActionID, FileID, UserID, ActionTimeStamp)
	  values (actionId, :OLD.FileID, userId, sysdate);
  select count(NodeFiles.FileID) into cnt from NodeFiles
    where :OLD.FileID = NodeFiles.FileID;
  if cnt = 0
    then
      delete from Files where FileID = :OLD.FileID;
      select first_value(FileActions.FileActionID) from FileActions
        where FileActions.FileActionName = 'Аннигилировать';
      insert into FilesLog(FileActionID, FileID, UserID, ActionTimeStamp)
	      values (actionId, :OLD.FileID, -1, sysdate);
    end if;
end NodeFiles_DEL_TRG;

------------------------------------------------------------FileActions
create table FileActions
(
  FileActionID NUMBER PRIMARY KEY NOT NULL,
  FileActionName VARCHAR2(50) NOT NULL
);

create sequence FileActions_SEQ;

create or replace trigger FileActions_TRG
before insert on FileActions
for each row
begin
	:NEW.FileActionID := FileActions_SEQ.nextval;
end FileActions_TRG;

create or replace trigger FileActions_DEL_TRG
before delete on FileActions
for each row
begin
  delete from FilesLog where FilesLog.FileActionID = :OLD.FileActionID;
end FileActions_DEL_TRG;

---------------------------------------------------------------FilesLog
CREATE TABLE FilesLog
(
	FilesLogID		NUMBER PRIMARY KEY NOT NULL,
	FileActionID	NUMBER NOT NULL,
	FileID			NUMBER NOT NULL,
	UserID			NUMBER NOT NULL,
	ActionTimeStamp	DATE NOT NULL,
	CONSTRAINT FileAction_FK FOREIGN KEY (FileActionID) REFERENCES FileActions(FileActionID)
	--CONSTRAINT FileLog_FK FOREIGN KEY (FileID) REFERENCES Files(FileID),
	--CONSTRAINT UserFileLog_FK FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

create sequence FilesLog_SEQ;

create or replace trigger FilesLog_TRG
before insert on FilesLog
for each row
begin
  :NEW.FilesLogID := FilesLog_SEQ.nextval;
end FilesLog_TRG;

-----------------------------------------------------------------------
-------------------   Extended operations section   -------------------
----------------------------------------------------------------Ratings

CREATE TABLE Ratings
(
	UserID	NUMBER NOT NULL,
	FileID	NUMBER NOT NULL,
	Value	NUMBER NOT NULL,
	PRIMARY KEY (UserID, FileID),
	CONSTRAINT UserRating_FK FOREIGN KEY (UserID) REFERENCES Users(UserID),
	CONSTRAINT FileRating_FK FOREIGN KEY (FileID) REFERENCES Files(FileID)
);

---------------------------------------------------------------Comments
CREATE TABLE Comments
(
	CommentID	NUMBER PRIMARY KEY NOT NULL,
	UserID		NUMBER NOT NULL,
	FileID		NUMBER NOT NULL,
	CommentText	VARCHAR2(1600) NOT NULL,
	CONSTRAINT UserComment_FK FOREIGN KEY (UserID) REFERENCES Users(UserID),
	CONSTRAINT FileComment_FK FOREIGN KEY (FileID) REFERENCES Files(FileID)
);

create sequence Comments_SEQ;

create or replace trigger Comments_TRG
before insert on Comments
for each row
begin
  :NEW.CommentID := Comments_SEQ.nextval;
end Comments_TRG;