#!/usr/bin/python2.7

from PyQt4 import QtGui, QtCore, QtSql
from FolderModel import *
DBFolderIDRole = QtCore.Qt.UserRole
 
class FolderView(QtGui.QDialog):
    def __init__(self, UserID, parent):
        QtGui.QDialog.__init__(self)
        self.setWindowTitle("Hierarchy Manager")
        self.UserID = UserID
        self.parent = parent
        self.folder = 0
        
        self.model = FolderModel()
        self.model.setQuery(self.execQuery())
        
        view = QtGui.QListView(self)
        view.setModel(self.model)
        view.setSpacing(10)
        view.setViewMode(QtGui.QListView.IconMode)
        view.doubleClicked.connect(self.doubleClicked)
        
        self.history = QtGui.QListWidget()
        self.history.setFlow(QtGui.QListView.LeftToRight)
        self.history.setMaximumHeight(25)
        self.history.itemClicked.connect(self.selectFolder)
        
        home = QtGui.QListWidgetItem('Home >')
        home.setData(DBFolderIDRole,0)
        self.history.addItem(home)
        self.history.setCurrentItem(self.history.item(0))
        
        self.FileName = QtGui.QLabel("File: ")
        self.Rating = QtGui.QLabel("Rating:")
        self.Shared = QtGui.QLabel("Rating:")
        CommentLabel = QtGui.QLabel("Comments")
        
        self.CommentsModel = QtSql.QSqlQueryModel()
        self.CommentsModel.setQuery(self.commentQuery(0))
        self.Comments = QtGui.QListView()
        self.Comments.setModel(self.CommentsModel)
        self.Comments.setModelColumn(2)
        self.Comments.setMaximumWidth(300)
        self.Comments.setSelectionMode(QtGui.QAbstractItemView.NoSelection)
        self.Comments.setWordWrap(True)
        
        main = QtGui.QHBoxLayout()
        
        box = QtGui.QVBoxLayout()
        box.addWidget(self.history)
        box.addWidget(view)
        main.addLayout(box)
        
        box = QtGui.QVBoxLayout()
        box.addWidget(self.FileName)
        box.addWidget(self.Rating)
        box.addWidget(self.Shared)
        box.addWidget(CommentLabel)
        box.addWidget(self.Comments)
        self.frame = QtGui.QFrame()
        self.frame.setLayout(box)
        self.frame.setVisible(False)
        main.addWidget(self.frame)
        self.setLayout(main)
        self.resize(700, 500)
        
    def execQuery(self):
        if self.folder>0:
            query = QtSql.QSqlQuery("select 1 as Type, NodeID as ID, NodeName as Name,\
                NULL as Icon, NULL as Rating, IsShared\
                from Nodes left join Edges on Nodes.NodeID=Edges.ChildID\
                where Nodes.UserID=? and Edges.ParentID=?\
                \
                union\
                \
                select 2 as Type, Files.FileID as ID, Files.Name as Name,\
                FileExtensions.Icon as Icon, Ratings.Value as Rating, Files.IsShared\
                from Files left join NodeFiles on NodeFiles.FileID=Files.FileID\
                left join FileExtensions on Files.ExtensionID=FileExtensions.ExtensionID\
                left join Ratings on Ratings.FileID=Files.FileID\
                where NodeFiles.NodeID=?;")
            query.bindValue(0, self.UserID);
            query.bindValue(1, self.folder);
            query.bindValue(2, self.folder);
        else:
            query = QtSql.QSqlQuery("select 1 as Type, NodeID as ID, NodeName as Name\
                from Nodes left join Edges on Nodes.NodeID=Edges.ChildID\
                where Nodes.UserID=? and Edges.ParentID is NULL")
            query.bindValue(0, self.UserID);
        
        query.exec_()
        return query;
    
    def commentQuery(self, fileID):
        query = QtSql.QSqlQuery("select Comments.commentID, Users.LoginWord, Comments.CommentText\
                                from Comments\
                                left join Users on Comments.UserID=Users.UserID\
                                where Comments.FileID=?;")
                                
        query.bindValue(0, fileID);
        query.exec_()
        return query
    
    def ratingStr(self, rating):
        s = ""
        for i in xrange(rating):
            s += "*"
        for i in xrange(rating,5):
            s += "-"
        return s
    
    def doubleClicked(self, index):
        self.frame.setVisible(False)
        if self.model.record(index.row()).value(0).toInt()[0]==1:
            self.folder = self.model.record(index.row()).value(1).toInt()[0]
            folder = QtGui.QListWidgetItem(self.model.record(index.row()).value(2).toString()+" >")
            folder.setData(DBFolderIDRole,self.folder)
            self.history.addItem(folder)
            self.history.setCurrentItem(self.history.item(self.history.count()-1))
            self.model.setQuery(self.execQuery())
        else:
            fileID = self.model.record(index.row()).value(1).toInt()[0]
            self.FileName.setText("File: " + self.model.record(index.row()).value(2).toString())
            self.Rating.setText("Rating: " + self.ratingStr(self.model.record(index.row()).value(4).toInt()[0]))
            self.Shared.setText("Shared: " + str(self.model.record(index.row()).value(5).toInt()[0]>0))
            print self.model.record(index.row()).value(4).toInt()[0]
            self.CommentsModel.setQuery(self.commentQuery(fileID))
            self.frame.setVisible(True)
        
    def selectFolder(self, item):
        self.frame.setVisible(False)
        self.folder = item.data(DBFolderIDRole).toInt()[0]
        self.model.setQuery(self.execQuery())
        hist = [(self.history.item(i).text(),self.history.item(i).data(DBFolderIDRole).toInt()[0]) for i in xrange(self.history.currentRow()+1)]
        self.history.clear()
        for item in hist:
            folder = QtGui.QListWidgetItem(item[0])
            folder.setData(DBFolderIDRole,item[1])
            self.history.addItem(folder)
        self.history.setCurrentItem(self.history.item(self.history.count()-1))