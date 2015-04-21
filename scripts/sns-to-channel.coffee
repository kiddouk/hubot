# Description:
#   Send the SNS notification to the appropriate channel
#

module.exports = (robot) ->

  room_topic_mapping =
    'ElasticBeanstalkNotifications-Environment-voyr': 'voyr'
    'Alarm-voyr': 'voyr'


  robot.on "sns:notification:Alarm-voyr", (msg) ->
    description = JSON.parse(msg.message)['AlarmDescription']
    explanation = "Topic: " + msg.topic + "\n"
    explanation += "Subject: " + msg.subject + "\n"
    explanation += "Description : " + description
    robot.messageRoom room, "Just received an AWS Alarm\n```" + explanation + "```" for topic, room of room_topic_mapping when topic == msg.topic
    
  robot.on "sns:notification:ElasticBeanstalkNotifications-Environment-voyr", (msg) ->
    message = msg.message
    result = message.match(/.*Message:([\s\S]*)Environment:.*/)
    try
      message = result[1]
    catch error
      console.log error
    try
      message = JSON.parse(message)
    catch error
      console.log error
    explanation = "Topic: " + msg.topic + "\n"
    explanation += "Subject: " + msg.subject + "\n"

    if typeof(message) == "object"
      explanation += "Description : " + message.Description + "\n"
      explanation += "Cause : " + message.Cause + "\n"
    else
      explanation += "Message : " + message
    robot.messageRoom room, "Just received an SNS Notification\n```" + explanation + "```" for topic, room of room_topic_mapping when topic == msg.topic
    
