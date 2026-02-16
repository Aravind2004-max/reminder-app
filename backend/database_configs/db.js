const mySql = require('mysql2');

//creating db connnection
const db = mySql.createConnection({
    host: "localhost",
    port: 3306,
    user: 'root',
    password: '12345678',
    database: 'reminder',
    dateStrings: true,
});

db.connect((err) => {
    if (!err) {
        console.log(`Database connected`);
        return;
    }
    console.log(`Database connection failed: ${err.message}`);
});



module.exports = db;