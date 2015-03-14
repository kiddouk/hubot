# Description:
#   Send the SNS notification to the appropriate channel
#

module.exports = (robot) ->

  room_topic_mapping =
    'ElasticBeanstalkNotifications-Environment-voyr': 'sandbox'
    
  robot.on "sns:notification", (msg) ->
    robot.messageRoom room, "[AWS Notification] *" + msg.topic + "* - " + msg.subject + "\n" + msg.message for topic, room of room_topic_mapping when topic == msg.topic
    
