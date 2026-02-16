const exp = require('express');
const router = exp.Router();
const controllers = require('../controllers/reminder.controller');

router.get('/home', controllers.getHomePage);

router.post('/alarm', controllers.postAlarmPage);

router.put('/cancelAlarm', controllers.cancelAlarm);

router.delete('/deleteScheduler', controllers.deleteScheduler);

router.put('/updateAlarm', controllers.alarmTimeUpdate);

router.put('/reminderUpdate', controllers.reminderUpdate);

router.post("/userIdCheck", controllers.checkUser);

module.exports = router;