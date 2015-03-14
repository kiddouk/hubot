# Description:
#   Send the SNS notification to the appropriate channel
#

module.exports = (robot) ->

  room_topic_mapping =
    'ElasticBeanstalkNotifications-Environment-voyr': 'voyr'
    
  robot.on "sns:notification", (msg) ->
    explanation = "Topic: " + msg.topic + "\n"
    explanation += "Subject: " + msg.subject + "\n"
    explanation += "Description : " + msg.message
    robot.messageRoom room, "Just received an SNS Notification\n```" + explanation + "```" for topic, room of room_topic_mapping when topic == msg.topic
    
