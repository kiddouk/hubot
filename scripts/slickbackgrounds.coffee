# Description:
#   Run the specified admin task with default + provided arguments
#
# Configuration
#   SLICKBACKGROUNDS_DB_DB_NAME - db name
#   SLICKBACKGROUNDS_DB_USER - user for authentication
#   SLICKBACKGROUNDS_DB_PASSWORD - password to user in authentication
#   SLICKBACKGROUNDS_DB_HOST - db host
#   AWS_SECRET_ACCESS_KEY - AWS secret access key
#   AWS_ACCESS_KEY_ID - AWS key id

AWS = require "aws-sdk"

module.exports = (robot) ->
  errorAnswers = ["Sorry man, I failed", "Ooops, something went wrong.", "I have a bug, which prevent me to honor your request"]
  successAnswers = ["Done and done.", "Ok, done. Is that all ?", "Consider it done.", "Only this ? That was easy"]
  robot.respond /give ([0-9]+) coins to (.*) on slickbackgrounds/, (res) ->
    lambda = new AWS.Lambda({apiVersion: '2015-03-31'});
    lambda.invoke {
      FunctionName: "SlickBackground-Task"
      InvocationType: "Event"
      LogType: "None"
      Payload:
        run: "setCredit"
        db_dbname: process.env.SLICKBACKGROUND_DB_DB_NAME
        db_host: process.env.SLICKBACKGROUND_DB_HOST
        db_user: process.env.SLICKBACKGROUND_DB_USER
        db_password: process.env.SLICKBACKGROUND_DB_PASSWORD
        device_id: res.match[2]
        credit: res.match[1]
    }, (err, data) ->
      if (err) res.send res.random errorAnswers
      else
        if (data.StatusCode) < 299
          res.response res.random.successAnswers
          return
        if (data.Payload == "No such User")
          res.send "Sorry, but I can't find any " + res.match[2] + " in my records."
          return
        res.send res.random.errorAnswers
          
