CREATE TABLESPACE HIERARCHYMANAGER DATAFILE 'C:\Users\Daniil\Oracle\app\oracle\oradata\XE\HIERARCHYMANAGER.DBF'
SIZE 100M REUSE AUTOEXTEND ON NEXT 10M MAXSIZE 200M;

-----------------------------------------------------------------------
---------------------   User operations section   ---------------------
------------------------------------------------------------------Users
CREATE TABLE Users
(
	UserID		NUMBER PRIMARY KEY NOT NULL,
	LoginWord	VARCHAR2(20) NOT NULL,
	PassPhrase	VARCHAR2(20) NOT NULL,
	FirstName	VARCHAR2(20),
	LastName	VARCHAR2(20)
)
tablespace HIERARCHYMANAGER;

create sequence Users_SEQ minvalue 1 maxvalue 100000 increment by 1 start with 1 nocycle;

create or replace trigger Users_TRG
before insert on Users
for each row
begin
  if :NEW.UserID is null then
    select Users_SEQ.nextval into :NEW.UserID from SYS.DUAL;
  end if;
end Users_TRG;
/

-----------------------------------------------------------------------
--------------------   Folder operations section   --------------------
------------------------------------------------------------------Nodes
CREATE TABLE Nodes
(
	NodeID		NUMBER PRIMARY KEY NOT NULL,
	NodeName	VARCHAR2(20) NOT NULL,
	UserID		NUMBER NOT NULL,
	IsShared	NUMBER NOT NULL,
    CONSTRAINT NodeUser_FK FOREIGN KEY (UserID) REFERENCES Users(UserID)
)
tablespace HIERARCHYMANAGER;

create sequence Nodes_SEQ minvalue 1 maxvalue 100000000 increment by 1 start with 1 nocycle;

create or replace trigger Nodes_TRG
before insert on Nodes
for each row
begin
  if :NEW.NodeID is null then
    select Nodes_SEQ.nextval into :NEW.NodeID from SYS.DUAL;
  end if;
end Nodes_TRG;
/

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
)
tablespace HIERARCHYMANAGER;

create sequence Edges_SEQ minvalue 1 maxvalue 100000000 increment by 1 start with 1 nocycle;

create or replace trigger Edges_TRG
before insert on Edges
for each row
begin
  if :NEW.EdgeID is null then
    select Edges_SEQ.nextval into :NEW.EdgeID from SYS.DUAL;
  end if;
end Edges_TRG;
/

------------------------------------------------------------NodeActions
create table NodeActions
(
  NodeActionID NUMBER PRIMARY KEY NOT NULL,
  NodeActionName VARCHAR2(20) NOT NULL
)
tablespace HIERARCHYMANAGER;

---------------------------------------------------------------NodesLog
CREATE TABLE NodesLog
(
	NodesLogID		NUMBER PRIMARY KEY NOT NULL,
	NodeActionID	NUMBER NOT NULL,
	NodeID			NUMBER NOT NULL,
	UserID			NUMBER NOT NULL,
	ActionTimeStamp	DATE NOT NULL,
	CONSTRAINT NodeAction_FK FOREIGN KEY (NodeActionID) REFERENCES NodeActions(NodeActionID),
	CONSTRAINT NodeLog_FK FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID),
	CONSTRAINT UserNodeLog_FK FOREIGN KEY (UserID) REFERENCES Users(UserID)
)
tablespace HIERARCHYMANAGER;

create sequence NodesLog_SEQ minvalue 1 maxvalue 10000000000 increment by 1 start with 1 nocycle;

create or replace trigger NodesLog_TRG
before insert on NodesLog
for each row
begin
  if :NEW.NodesLogID is null then
    select NodesLog_SEQ.nextval into :NEW.NodesLogID from SYS.DUAL;
  end if;
end NodesLog_TRG;
/

-----------------------------------------------------------------------
---------------------   File operations section   ---------------------
---------------------------------------------------------FileExtensions
CREATE TABLE FileExtensions
(
	ExtensionID	NUMBER PRIMARY KEY NOT NULL,
	Mask		VARCHAR2(12) NOT NULL,
	Description	VARCHAR2(80) NOT NULL,
    Icon        VARCHAR2(20)
)
tablespace HIERARCHYMANAGER;

create sequence FileExt_SEQ minvalue 1 maxvalue 100000 increment by 1 start with 1 nocycle;

create or replace trigger FileExt_TRG
before insert on FileExtensions
for each row
begin
  if :NEW.ExtensionID is null then
    select FileExt_SEQ.nextval into :NEW.ExtensionID from SYS.DUAL;
  end if;
end FileExt_TRG;
/

------------------------------------------------------------------Files
CREATE TABLE Files
(
	FileID		NUMBER PRIMARY KEY NOT NULL,
	Name		VARCHAR2(20) NOT NULL,
	ExtensionID NUMBER,
	FileData	BLOB,
	IsShared	NUMBER NOT NULL,
	CONSTRAINT Extension_FK FOREIGN KEY (ExtensionID) REFERENCES FileExtensions(ExtensionID)
)
tablespace HIERARCHYMANAGER;

create sequence Files_SEQ minvalue 1 maxvalue 100000000 increment by 1 start with 1 nocycle;

create or replace trigger Files_TRG
before insert on Files
for each row
begin
  if :NEW.FileID is null then
    select Files_SEQ.nextval into :NEW.FileID from SYS.DUAL;
  end if;
end Files_TRG;
/

--------------------------------------------------------------NodeFiles
CREATE TABLE NodeFiles
(
	NodeID	NUMBER NOT NULL,
	FileID	NUMBER NOT NULL,
	PRIMARY KEY (NodeID, FileID),
	CONSTRAINT Node_FK FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID),
	CONSTRAINT File_FK FOREIGN KEY (FileID) REFERENCES Files(FileID)
)
tablespace HIERARCHYMANAGER;

------------------------------------------------------------FileActions
create table FileActions
(
  FileActionID NUMBER PRIMARY KEY NOT NULL,
  FileActionName VARCHAR2(20) NOT NULL
)
tablespace HIERARCHYMANAGER;

---------------------------------------------------------------FilesLog
CREATE TABLE FilesLog
(
	FilesLogID		NUMBER PRIMARY KEY NOT NULL,
	FileActionID	NUMBER NOT NULL,
	FileID			NUMBER NOT NULL,
	UserID			NUMBER NOT NULL,
	ActionTimeStamp	DATE NOT NULL,
	CONSTRAINT FileAction_FK FOREIGN KEY (FileActionID) REFERENCES FileActions(FileActionID),
	CONSTRAINT FileLog_FK FOREIGN KEY (FileID) REFERENCES Files(FileID),
	CONSTRAINT UserFileLog_FK FOREIGN KEY (UserID) REFERENCES Users(UserID)
)
tablespace HIERARCHYMANAGER;

create sequence FilesLog_SEQ minvalue 1 maxvalue 10000000000 increment by 1 start with 1 nocycle;

create or replace trigger FilesLog_TRG
before insert on FilesLog
for each row
begin
  if :NEW.FilesLogID is null then
    select FilesLog_SEQ.nextval into :NEW.FilesLogID from SYS.DUAL;
  end if;
end FilesLog_TRG;
/

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
)
tablespace HIERARCHYMANAGER;

---------------------------------------------------------------Comments
CREATE TABLE Comments
(
	CommentID	NUMBER PRIMARY KEY NOT NULL,
	UserID		NUMBER NOT NULL,
	FileID		NUMBER NOT NULL,
	CommentText	VARCHAR2(800) NOT NULL,
	CONSTRAINT UserComment_FK FOREIGN KEY (UserID) REFERENCES Users(UserID),
	CONSTRAINT FileComment_FK FOREIGN KEY (FileID) REFERENCES Files(FileID)
)
tablespace HIERARCHYMANAGER;

create sequence Comments_SEQ minvalue 1 maxvalue 10000000000 increment by 1 start with 1 nocycle;

create or replace trigger Comments_TRG
before insert on Comments
for each row
begin
  if :NEW.CommentID is null then
    select Comments_SEQ.nextval into :NEW.CommentID from SYS.DUAL;
  end if;
end Comments_TRG;
/
