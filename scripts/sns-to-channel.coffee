# Description:
#   Send the SNS notification to the appropriate channel
#

module.exports = (robot) ->

  room_topic_mapping =
    'ElasticBeanstalkNotifications-Environment-voyr': 'sandbox'
    'Alarm-voyr': 'sandbox'


  robot.on "sns:notification:Alarm-voyr", (msg) ->
    message = JSON.parse(msg.message)['Description']
    explanation = "Topic: " + msg.topic + "\n"
    explanation += "Subject: " + msg.subject + "\n"
    explanation += "Description : " + message
    robot.messageRoom room, "Just received an AWS Alarm\n```" + explanation + "```" for topic, room of room_topic_mapping when topic == msg.topic
    
  robot.on "sns:notification:ElasticBeanstalkNotifications-Environment-voyr", (msg) ->
    result = msg.message.match(/Message:(.*)Environment:/)
    try
      message = result[1]
    catch error
      message = msg.message
    explanation = "Topic: " + msg.topic + "\n"
    explanation += "Subject: " + msg.subject + "\n"
    explanation += "Description : " + message
    robot.messageRoom room, "Just received an SNS Notification\n```" + explanation + "```" for topic, room of room_topic_mapping when topic == msg.topic
    
