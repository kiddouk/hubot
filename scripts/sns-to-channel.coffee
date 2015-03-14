# Description:
#   Send the SNS notification to the appropriate channel
#

module.exports = (robot) ->

  room_topic_mapping =
    'ElasticBeanstalkNotifications-Environment-voyr': 'sandbox'
    
  robot.on "sns:notification", (msg) ->
    message = JSON.parse msg.message
    explanation = "Topic: " + msg.topic + "\n"
    explanation += "Subject: " + msg.subject + "\n"
    explanation += "Description : " + message['AlarmDescription']
    robot.messageRoom room, "Just received an SNS Notification\n```" + explanation + "```" for topic, room of room_topic_mapping when topic == msg.topic
    
