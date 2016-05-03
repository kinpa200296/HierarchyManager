--Login
create or replace function Login(
  uName VARCHAR2,
  pWord VARCHAR2
)
return number as
  EnterUserID number;
begin

  select (select UserID from users where LoginWord=uName and PassPhrase=pWord)
  into EnterUserID from dual;

  return EnterUserID;
  
end Login;
/

--Selecting comments
create or replace type rowGetComments as object(
commentID number,
Username VARCHAR2(20),
CommentText VARCHAR2(800)
);
/
create or replace type rowsGetComments as table of rowGetComments;
/
create or replace function GetComments(fID number)
  return rowsGetComments
  as rowsComments rowsGetComments;
begin
  select cast( multiset(
    select Comments.commentID, Users.LoginWord, Comments.CommentText
    from Comments left join Users on Comments.UserID=Users.UserID
    where Comments.FileID = fID) as rowsGetComments) into rowsComments from dual;

  return rowsComments;
end GetComments;
/
--select * from table(GetComments(1));

--Selecting from directory
create or replace type rowGetDirContent as object(
  cType number,
  cID number,
  cName VARCHAR2(20),
  cIcon VARCHAR2(20),
  cRating number
);
/
create or replace type rowsGetDirContent as table of rowGetDirContent;
/
create or replace function GetDirContent(
  uName VARCHAR2,
  pWord VARCHAR2,
  pUserID number,
  pfID number
)
return rowsGetDirContent is
  rowsDirContent rowsGetDirContent;
  x rowsGetDirContent;
  myUserID number;
  folderUserID number;
  actionID number;
  
  procedure AppendToTable (
    src IN OUT rowsGetDirContent,
    x IN rowsGetDirContent
  ) is
  begin
    for iter in 1 .. x.COUNT loop
      src.extend();
      src(src.COUNT) := x(iter);
    end loop;
  end AppendToTable;
  
begin
  select Login(uName, pWord) into myUserID from dual;  
  
  if pfID=0 then
    begin
      if pUserID=myUserID then
        begin
          select cast( multiset(
            select 1 as cType, Nodes.NodeID as cID, Nodes.NodeName as cName,
              NULL as cIcon, NULL as cRating
            from Nodes left join Edges on Nodes.NodeID=Edges.ChildID
            where Nodes.UserID = pUserID and Edges.ParentID=NULL
          ) as rowsGetDirContent) into x from dual;
          
          AppendToTable(rowsDirContent, x);
        
          select cast( multiset(          
            select 0 as cType, UserID as cID, LoginWord as cName,
              NULL as cIcon, NULL as cRating
            from Users
            where UserID in (select userID from nodes where IsShared=1 
              group by UserID having count(*)>0) and UserID<>myUserID
          ) as rowsGetDirContent) into x from dual;  
          
          AppendToTable(rowsDirContent, x);
        end;  
      else
        begin      
          select cast( multiset(
            select 1 as cType, Nodes.NodeID as cID, Nodes.NodeName as cName,
              NULL as cIcon, NULL as cRating
            from Nodes left join Edges on Nodes.NodeID=Edges.ChildID
            where Nodes.UserID = pUserID and Edges.ParentID=NULL)
          as rowsGetDirContent) into x from dual;
          
          AppendToTable(rowsDirContent, x);  
        end;
      end if;
    end;
    
  else
    begin
      select UserID into folderUserID from Nodes where NodeID = folderUserID;
      
      select NodeActions.NodeActionID into actionID from NodeActions
      where NodeActions.NodeActionName = 'Открыть';
      
      insert into NodesLog(NodeActionID, NodeID, UserID) values(2, pfID, myUserID);
      
      if folderUserID=myUserID then
        begin
          select cast( multiset(
            select 1 as cType, Nodes.NodeID as cID, Nodes.NodeName as cName,
              NULL as cIcon, NULL as cRating
            from Nodes left join Edges on Nodes.NodeID=Edges.ChildID
            where Edges.ParentID=pfID
          ) as rowsGetDirContent) into x from dual;  
      
          AppendToTable(rowsDirContent, x);
        end;
      else
        begin
          select cast( multiset(
            select 1 as cType, Nodes.NodeID as cID, Nodes.NodeName as cName,
              NULL as cIcon, NULL as cRating
            from Nodes left join Edges on Nodes.NodeID=Edges.ChildID
            where Edges.ParentID=pfID and Nodes.ISSHARED<>0)
          as rowsGetDirContent) into x from dual;
          
          AppendToTable(rowsDirContent, x);
        end;
      end if;  

      select cast( multiset(
        select 2 as Type, Files.FileID as ID, Files.Name as Name,
            FileExtensions.Icon as Icon, Ratings.Value as Rating, Files.IsShared
        from Files left join NodeFiles on NodeFiles.FileID=Files.FileID
            left join FileExtensions on Files.ExtensionID=FileExtensions.ExtensionID
            left join Ratings on Ratings.FileID=Files.FileID
        where NodeFiles.NodeID=pfID
      ) as rowsGetDirContent) into x from dual;    
      
      AppendToTable(rowsDirContent, x);
      
    end;  
  end if;
  
  return rowsDirContent;
end GetDirContent;
/

--Creating comment
create or replace procedure MakeComment(
  uName VARCHAR2,
  pWord VARCHAR2,
  fID number,
  Text varchar2
) is
  userID number;
begin
  select Login(uName, pWord) into userID from dual;  
  insert into Comments(UserID, FileID, CommentText) values (userID, fID, Text);
end MakeComment;
/

--Inserting folder into existing folder
create or replace procedure InsertEdge(
  uName VARCHAR2,
  pWord VARCHAR2,
  cNodeID number,
  cParentID number  
) is
  userID number;
begin
  select Login(uName, pWord) into userID from dual;  
  INSERT INTO Edges(ChildID, ParentID, UserID) VALUES (cNodeID, cParentID, userID);
end;
/

--Inserting file into existing folder
create or replace procedure InsertFile(
  uName VARCHAR2,
  pWord VARCHAR2,
  cFileID number,
  cParentID number  
) is
  userID number;
begin
  INSERT INTO NodeFiles(NodeID, FileID) VALUES (cParentID, cFileID); 
end;
/