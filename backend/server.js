const exp = require('express');
const app = exp();
const cors = require('cors');
const port = 2000;
const db = require('./database_configs/db');
const routes = require('./routes/reminder.route');

app.use(exp.json());
app.use(cors());
app.use('/reminder', routes);

app.listen(port, (err) => {
    if (!err) {
        console.log(`Server started: http://localhost:${port}/`);
        return;
    }
    console.log(`Erro on server: ${err.message}`);
});