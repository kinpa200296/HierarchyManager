CREATE TABLESPACE HIERARCHYMANAGER DATAFILE 'C:\Users\Daniil\Oracle\app\oracle\oradata\XE\HIERARCHYMANAGER.DBF'
SIZE 100M REUSE AUTOEXTEND ON NEXT 10M MAXSIZE 200M;

------------------------------------------------------------NodeActions
create table NodeActions
(
  NodeActionID NUMBER PRIMARY KEY,
  NodeActionName VARCHAR2(20)
)
tablespace HIERARCHYMANAGER;

alter table NodeActions modify (NodeActionID NOT NULL enable);
alter table NodeActions modify (NodeActionName NOT NULL enable);

------------------------------------------------------------FileActions
create table FileActions
(
  FileActionID NUMBER PRIMARY KEY,
  FileActionName VARCHAR2(20)
)
tablespace HIERARCHYMANAGER;

alter table FileActions modify (FileActionID NOT NULL enable);
alter table FileActions modify (FileActionName NOT NULL enable);

---------------------------------------------------------FileExtensions
CREATE TABLE FileExtensions
(
	ExtensionID	NUMBER PRIMARY KEY,
	Mask		VARCHAR2(12),
	Extension	VARCHAR2(80),
    Icon        VARCHAR2(20)
)
tablespace HIERARCHYMANAGER;

alter table FileExtensions modify (ExtensionID NOT NULL enable);
alter table FileExtensions modify (Mask NOT NULL enable);
alter table FileExtensions modify (Extension NOT NULL enable);

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
alter trigger FileExt_TRG enable;

------------------------------------------------------------------Users
CREATE TABLE Users
(
	UserID		NUMBER PRIMARY KEY,
	LoginWord	VARCHAR2(20),
	PassPhrase	VARCHAR2(20),
	FirstName	VARCHAR2(20),
	LastName	VARCHAR2(20)
)
tablespace HIERARCHYMANAGER;

alter table Users modify (UserID NOT NULL enable);
alter table Users modify (LoginWord NOT NULL enable);
alter table Users modify (PassPhrase NOT NULL enable);

create sequence Users_SEQ minvalue 1 maxvalue 100000 increment by 1 start with 1 nocycle;

create or replace trigger Users_TRG
before insert on Users
for each row
begin
  if :NEW.NodeID is null then
    select Users_SEQ.nextval into :NEW.UserID from SYS.DUAL;
  end if;
end Users_TRG;
/
alter trigger Users_TRG enable;

------------------------------------------------------------------Nodes
CREATE TABLE Nodes
(
	NodeID		NUMBER PRIMARY KEY,
	NodeName	VARCHAR2(20),
	UserID		NUMBER,
	IsShared	NUMBER,
    CONSTRAINT NodeUser_FK FOREIGN KEY (UserID) REFERENCES Users(UserID)
)
tablespace HIERARCHYMANAGER;

alter table Nodes modify (NodeID NOT NULL enable);
alter table Nodes modify (NodeName NOT NULL enable);
alter table Nodes modify (UserID NOT NULL enable);
alter table Nodes modify (IsShared NOT NULL enable);

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
alter trigger Nodes_TRG enable;

------------------------------------------------------------------Edges
CREATE TABLE Edges
(
	EdgeID		NUMBER PRIMARY KEY,
	ChildID		NUMBER,
	ParentID	NUMBER,
	UserID		NUMBER,
	CONSTRAINT ChildNode_FK FOREIGN KEY (ChildID) REFERENCES Nodes(NodeID),
	CONSTRAINT ParentNode_FK FOREIGN KEY (ParentID) REFERENCES Nodes(NodeID),
	CONSTRAINT UserEdge_FK FOREIGN KEY (UserID) REFERENCES Users(UserID)
)
tablespace HIERARCHYMANAGER;

alter table Edges modify (EdgeID NOT NULL enable);
alter table Edges modify (ChildID NOT NULL enable);
alter table Edges modify (ParentID NOT NULL enable);
alter table Edges modify (UserID NOT NULL enable);

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
alter trigger Edges_TRG enable;

------------------------------------------------------------------Files
CREATE TABLE Files
(
	FileID		NUMBER PRIMARY KEY,
	Name		VARCHAR2(20),
	ExtensionID NUMBER,
	FileData	BLOB,
	IsShared	NUMBER,
	CONSTRAINT Extension_FK FOREIGN KEY (ExtensionID) REFERENCES FileExtensions(ExtensionID)
)
tablespace HIERARCHYMANAGER;

alter table Files modify (FileID NOT NULL enable);
alter table Files modify (Name NOT NULL enable);
alter table Files modify (IsShared NOT NULL enable);

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
alter trigger Files_TRG enable;

--------------------------------------------------------------NodeFiles
CREATE TABLE NodeFiles
(
	NodeID	NUMBER,
	FileID	NUMBER,
	PRIMARY KEY (NodeID, FileID),
	CONSTRAINT Node_FK FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID),
	CONSTRAINT File_FK FOREIGN KEY (FileID) REFERENCES Files(FileID)
)
tablespace HIERARCHYMANAGER;

alter table NodeFiles modify (NodeID NOT NULL enable);
alter table NodeFiles modify (FileID NOT NULL enable);