# Description:
#   Send the SNS notification to the appropriate channel
#

module.exports = (robot) ->

  room_topic_mapping =
    'ElasticBeanstalkNotifications-Environment-voyr': 'voyr'
    
  robot.on "sns:notification", (msg) ->
    robot.messageRoom room, msg.subject for topic, room of room_topic_mapping when topic == msg.topic
    
