import oracledb

def get_connection():
    return oracledb.connect(
        user="sys",
        password="your_Password",
        dsn="localhost:1521/xe"
    )