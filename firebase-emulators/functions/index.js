const auth = require("./auth/index.js");

exports.authBeforeCreate = auth.beforeCreate;
exports.authCheckForBan = auth.checkForBan;
