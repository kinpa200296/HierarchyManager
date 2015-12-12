import json

class DbConfig(object):

    def load(self):
        with open('config.json', 'r') as f:
            self.data = json.loads(f.readline())

    def config(self, db):
        db.setHostName(self.data["hostname"])
        db.setPort(self.data["port"])
        db.setDatabaseName(self.data["databaseName"])
        db.setUserName(self.data["username"])
        db.setPassword(self.data["password"])