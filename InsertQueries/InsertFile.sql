--Добавление файла в папку с заданным ID
--INSERT INTO Files(Name, ExtensionID, FileData, IsShared) VALUES ([Имя], [ID расширения], LOAD_FILE([Имя физического файла], [Доступ]);
--INSERT INTO NodeFiles(NodeID, FileID) VALUES ([ID Родительского каталога], [ID файла]);
declare
  d blob;
  f bfile;
begin
  INSERT INTO Files(Name, ExtensionID, FileData, IsShared)
    VALUES ('Марсианин(2015)', (select ExtensionID from FileExtensions where Mask='*.avi'), empty_blob(), 0)
      RETURNING FILEDATA into d;
  f := bfilename('e:\downloads\', 'save.dat');
  dbms_lob.fileopen(f);
  d := dbms_lob.LOADBLOBFROMFILE(d, f, dbms_lob.getlength(f), 0, 0);
  dbms_lob.fileclose(f);
  INSERT INTO NodeFiles VALUES ((select NodeID from Nodes where NodeName='folder'),
                                (select FileID from Files where Name='Марсианин(2015)'));
end;