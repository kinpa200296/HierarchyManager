#!/usr/bin/python2.7
 
import sys
from PyQt4 import QtGui, QtCore, QtSql
from FolderView import *
from DbConfig import DbConfig

 
class LoginForm(QtGui.QDialog):
    def __init__(self):
        QtGui.QDialog.__init__(self)
        
        self.setWindowTitle("Hierarchy Manager")
        
        db = QtSql.QSqlDatabase.addDatabase("QMYSQL")
        config = DbConfig()
        config.load()
        config.config(db)
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