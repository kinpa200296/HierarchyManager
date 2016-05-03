import json
import cx_Oracle

class DbConfig(object):

    def load(self):
        with open('config.json', 'r') as f:
            self.data = json.loads(f.readline())

    def connect(self):
        db = cx_Oracle.connect(self.data["username"], self.data["password"],
                               ":".join([self.data["hostname"], self.data["port"]]) + "/XE")
        #db.setHostName(self.data["hostname"])
        #db.setPort(self.data["port"])
        #db.setDatabaseName(self.data["databaseName"])
        #db.setUserName(self.data["username"])
        #db.setPassword(self.data["password"])
        return db