#!/usr/bin/python2.7
 
import sys
from PyQt4 import QtGui, QtCore, QtSql

DBFolderIDRole = QtCore.Qt.UserRole

class MySQLQueryModel(QtSql.QSqlQueryModel): 
    def __init__(self):
        QtSql.QSqlQueryModel.__init__(self)
        
    def data (self, index, role):
        if index.isValid() and role==QtCore.Qt.DisplayRole:
            return self.record(index.internalId()).value(2).toString()
        elif index.isValid() and role==QtCore.Qt.DecorationRole:
            type = self.record(index.internalId()).value(0).toInt()[0]
            if type==1:
                icon = QtGui.QIcon("folder.png")
            else:
                icon = QtGui.QIcon("file.png")
            return icon
        else:
            return QtSql.QSqlQueryModel.data(self, index, role)
 
class FolderView(QtGui.QDialog):
    def __init__(self, UserID, parent):
        QtGui.QDialog.__init__(self)
        self.setWindowTitle("Hierarchy Manager")
        self.UserID = UserID
        self.parent = parent
        self.folder = 0
        
        self.model = MySQLQueryModel()
        self.model.setQuery(self.execQuery())
        
        view = QtGui.QListView(self)
        view.setModel(self.model)
        #view.setModelColumn(2)
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
        
        box = QtGui.QVBoxLayout()
        box.addWidget(self.history)
        box.addWidget(view)
        self.setLayout(box)
        self.resize(620, 400)
        
    def execQuery(self):
        if self.folder>0:
            query = QtSql.QSqlQuery("select 1 as Type, NodeID as ID, NodeName as Name\
                from Nodes left join Edges on Nodes.NodeID=Edges.ChildID\
                where Nodes.UserID=? and Edges.ParentID=?\
                \
                union\
                \
                select 2 as Type, Files.FileID as ID, Files.Name as Name\
                from Files left join NodeFiles on NodeFiles.FileID=Files.FileID\
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
    
    def doubleClicked(self, index):
        if self.model.record(index.internalId()).value(0).toInt()[0]==1:
            self.folder = self.model.record(index.internalId()).value(1).toInt()[0]
            folder = QtGui.QListWidgetItem(self.model.record(index.internalId()).value(2).toString()+" >")
            folder.setData(DBFolderIDRole,self.folder)
            self.history.addItem(folder)
            self.history.setCurrentItem(self.history.item(self.history.count()-1))
            self.model.setQuery(self.execQuery())
        
    def selectFolder(self, item):
        self.folder = item.data(DBFolderIDRole).toInt()[0]
        self.model.setQuery(self.execQuery())
        hist = [(self.history.item(i).text(),self.history.item(i).data(DBFolderIDRole).toInt()[0]) for i in xrange(self.history.currentRow()+1)]
        self.history.clear()
        for item in hist:
            folder = QtGui.QListWidgetItem(item[0])
            folder.setData(DBFolderIDRole,item[1])
            self.history.addItem(folder)
        self.history.setCurrentItem(self.history.item(self.history.count()-1))
 
class LoginForm(QtGui.QDialog):
    def __init__(self):
        QtGui.QDialog.__init__(self)
        
        self.setWindowTitle("Hierarchy Manager")
        
        db = QtSql.QSqlDatabase.addDatabase("QMYSQL")
        db.setHostName("localhost");
        db.setDatabaseName("hierarchymanager");
        db.setUserName("root")
        ok = db.open()
        
        if not ok:
            QtGui.QMessageBox.critical(self, "Error", "Database not connected. You will not be able to log in.")

        login = QtGui.QLabel("Login")
        password = QtGui.QLabel("Password")
        self.loginEdit = QtGui.QLineEdit(self)
        self.passwordEdit = QtGui.QLineEdit(self)
        self.passwordEdit.setEchoMode(QtGui.QLineEdit.Password)
        button = QtGui.QPushButton("Enter")
        self.connect(button, QtCore.SIGNAL("clicked()"), self.tryToLogin)
        
        self.loginEdit.setText("user")
        self.passwordEdit.setText("qwerty")
        
        grid = QtGui.QGridLayout()
        grid.setSpacing(10)
        
        grid.addWidget(login,1,0)
        grid.addWidget(self.loginEdit,1,1)
        grid.addWidget(password,2,0)
        grid.addWidget(self.passwordEdit,2,1)
        grid.addWidget(button,3,1)
        
        self.setLayout(grid)
        self.resize(120, 80)
        
    def tryToLogin(self):
        query = QtSql.QSqlQuery("SELECT UserId from users where LoginWord=? and PassPhrase=?")
        query.bindValue(0, self.loginEdit.text())
        query.bindValue(1, self.passwordEdit.text())
        result = query.exec_()
        grid = self.layout()
        label = QtGui.QLabel()
        if result:
            if query.size()>0:
                query.first() 
                self.view = FolderView(query.value(0).toInt()[0], self)
                self.view.show()
                self.hide()
            else:
                QtGui.QMessageBox.critical(self, "Error", "Wrong username/password")
        else:
            print query.lastError().databaseText()

app = QtGui.QApplication(sys.argv)
form = LoginForm()
form.show()
app.exec_()