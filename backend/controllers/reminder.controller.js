const db = require('../database_configs/db');

const getHomePage = (req, res) => {
    try {
        const { id } = req.body;
        let sql = 'select * from `user_reminder` where user_id = ?'
        db.query(sql, [id], (err, results) => {
            if (!err) {
                return res.status(200).json(results);
            }
            return res.status(500).json({
                sqlError: err.message
            })
        });
    } catch (err) {
        return res.status(404).json({
            Error: err.message
        })
    }
}

const postAlarmPage = (req, res) => {
    try {
        const { id, reminder, time, period, isActive, userId } = req.body;
        let sql = 'insert into `user_reminder` values(?,?,?,?,?,?)';
        db.query(sql, [id, reminder, time, period, isActive, userId], (err, result) => {
            if (!err) {
                if (result.affectedRows > 0) {
                    return res.status(200).json({ inserted: true });
                }
                return res.status(200).json({ inserted: false });
            }
            console.log(`Error while inserting: ${err}`);
            return res.status(500).json({
                sqlError: err.messages
            });
        });
    } catch (err) {
        return res.status(404).json({
            Error: err.message
        });
    }
}

const cancelAlarm = (req, res) => {
    try {
        const { id, isActive } = req.query;
        const sql = 'update `user_reminder` set isActive = ? where id = ?';
        db.query(sql, [Boolean(isActive === 'true'), id], (err, result) => {
            if (err) {
                console.log(err.message)
                return res.status(500).json({ 'errorSQL': err.message });
            }
            if (result.affectedRows > 0) {
                return res.status(200).json({ updated: true });
            }
            return res.status(200).json({ updated: false });
        })
    } catch (err) {
        return res.status(404).json({ notFound: err.message });
    }
}

const deleteScheduler = (req, res) => {
    try {
        const { id } = req.query;
        const sql = 'delete from `user_reminder` where id = ?';
        db.query(sql, [id], (err, result) => {
            if (err) {
                return res.status(500).json({ errorSQL: err.message });
            }
            if (result.affectedRows > 0) {
                return res.status(200).json({ deleted: true });
            }
            return res.status(200).json({ deleted: false });
        })
    } catch (err) {
        return res.status(404).json({ notFound: err.msg });
    }
}

const alarmTimeUpdate = (req, res) => {
    try {
        const { id, time } = req.query;
        const sql = "update `user_reminder` set alarm_time = ? where id = ?";
        db.query(sql, [time, id], (err, result) => {
            if (err) {
                return res.status(500).json({ 'updated': false, 'msg': err.message });
            }
            if (result.affectedRows > 0) {
                return res.status(200).json({ updated: true });
            }
            return res.status(200).json({ updated: false });
        });
    } catch (err) {
        return res.status(404).json({ msg: err.message });
    }
}

const reminderUpdate = (req, res) => {
    try {
        const { id, desp } = req.query;
        console.log(id, desp)
        const sql = 'update `user_reminder` set description = ? where id = ?';
        db.query(sql, [desp, id], (err, result) => {
            if (err) {
                return res.status(500).json({ msg: err.message });
            }
            console.log(result.affectedRows);
            if (result.affectedRows > 0) {
                return res.status(200).json({ updated: true });
            }
            return res.status(200).json({ updated: false });
        });
    } catch (err) {
        return res.status(404).json({ msg: err.message });
    }
}

const checkUser = (req, res) => {
    try {
        const { id } = req.query;
        console.log(id);
        const sql = "call checkUser(?,@status)";
        const sessionSql = "select @status as status";
        db.query(sql, [id], (err) => {
            if (err) {
                return res.status(500).json({ "serverError": err.message });
            }
            db.query(sessionSql, (error, result) => {
                if (error) {
                    return res.status(500).json({ "serverError": error.message });
                }
                const status = Boolean(result[0].status);
                if (status) {
                    return res.status(200).json({ 'status': status });
                }
                return res.status(200).json({ 'status': status });
            });
        });
    } catch (err) {
        return res.status(404).json({ msg: err.message });
    }
}

module.exports = { getHomePage, postAlarmPage, cancelAlarm, deleteScheduler, alarmTimeUpdate, reminderUpdate, checkUser };