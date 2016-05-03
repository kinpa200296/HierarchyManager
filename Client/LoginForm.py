#!/usr/bin/python2.7
 
import sys
from PyQt4 import QtGui, QtCore, QtSql, uic
from FolderView import *
from DbConfig import DbConfig

class RegisterForm(QtGui.QDialog):
    def __init__(self, parent):
        QtGui.QDialog.__init__(self, parent)
        self.ui = uic.loadUi("RegisterForm.ui", self)
        self.connect(self.ui.acceptButton, QtCore.SIGNAL("clicked()"), self.accept)
        self.connect(self.ui.declineButton, QtCore.SIGNAL("clicked()"), self.close)
    
    def accept(self):
        if (self.ui.passwordEdit.text()==self.ui.passwordEdit_2.text()):
            query = QtSql.QSqlQuery("INSERT INTO Users(LoginWord, PassPhrase, FirstName, LastName, RootNodeID)\
                                    VALUES (?, ?, ?, ?, NULL);")
            query.bindValue(0, self.ui.usernameEdit.text())
            query.bindValue(1, self.ui.passwordEdit.text())
            query.bindValue(2, self.ui.nameEdit.text())
            query.bindValue(3, self.ui.surnameEdit.text())
            query.exec_()
            self.close()
        else:
            QtGui.QMessageBox.critical(self, "Error", "Passwords does not match!")
        
class LoginForm(QtGui.QDialog):
    def __init__(self):
        QtGui.QDialog.__init__(self)
        self.ui = uic.loadUi("LoginForm.ui", self)
        
        self.connect(self.ui.enterButton, QtCore.SIGNAL("clicked()"), self.tryToLogin)
        self.connect(self.ui.registerButton, QtCore.SIGNAL("clicked()"), self.register)
        # db = QtSql.QSqlDatabase.addDatabase("QOCI")
        config = DbConfig()
        config.load()
        db = config.connect()

        print dir(db)
        print db.version

        c = db.cursor()
        res = c.execute("SELECT * from FileExtensions")
        print res
        print c.description
        #if not ok:
           # QtGui.QMessageBox.critical(self, "Error", "Database not connected. You will not be able to log in.")
    
    def register(self):
        self.register = RegisterForm(self)
        self.register.open()
    
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
                self.view = FolderView(self, query.value(0).toInt()[0])
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