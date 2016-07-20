# Description:
#    Runs deployments on TEST and PRODUCTION plateform by simply making
#    the appropriate commit to the right branch.
#
# Commands:
#    hubot deploy branch my_branch from kiddouk/group/repository to test
#
# Configuration:
#    GITLAB_TOKEN - a private token
#    GITLAB_URL - the base url for the gitlab server.

gitlab = require("gitlab-api-client")(process.env.HUBOT_GITLAB_TOKEN, process.env.HUBOT_GITLAB_URL)

module.exports = (robot) ->

  robot.respond /deploy ([0-9A-Za-z_\\/\\-]+) from ([0-9A-Za-z_\\/\\-]+) to (staging|production)/, (res) ->
    project = encodeURIComponent(res.match[2])
    branch =  encodeURIComponent(res.match[1])
    gitlab.projects(project)
      .repository()
      .branches(branch)
      .get undefined, (err, response, repo) ->
        if err? or response.statusCode != 200
          return res.send "An error occured while trying to fetch " + res.match[2] + "#" + res.match[1] + ". Does is exists ?"
        gitlab.projects(project)
          .repository()
          .compare()
          .get {from: res.match[1], to: "master"}, (err, response, diff) ->
            if err? or response.statusCode != 200
              return res.send "It seems that I cannot make a git diff between master and " + res.match[1] + ". Are you sure that the branch exists?"
            if diff.diffs.length > 0
              return gitlab.projects(project)
                .merge_requests()
                .post {
                  source_branch: "master"
                  target_branch: res.match[1]
                  title: "Automatic merge of master branch to prepare deployment to " + res.match[3]
                  description: "Triggered by " + res.message.user.name
                  }, (err, response, mr) ->
                    if err? or response.statusCode != 201
                      return res.send "master branch is not merged yet and I cannot create a merge request. Aborting."
                    gitlab.projects(project)
                      .merge_requests(mr.id)
                      .merge()
                      .put {}, (err, response, m) ->
                        if response.statusCode == 405
                          return close_merge_request mr.id, project, "Merging master would bring conflict, You have to merge master manually first.", res
                        if response.statusCode == 406
                          return close_merge_request mr.id, project, "I cannot merge my own merge_request #" + mr.id + " in " + res.match[1] + " branch. Do it for me and summon me again", res
                        if err? or response.statusCode != 200
                          return res.send "An unknown error occured while accepting my own merge_request #" + mr.id + ". Aborting here and you have to debug. kthxbye."
                        return tag_repo_for_deployment res.match[1], project, res.match[3], res.message.user.name, res
                        
                  
              return res.send "The branch " + res.match[1] + " is not up to date with master branch. Merge it first, then come back here."
            return tag_repo_for_deployment res.match[1], project, res.match[3], res.message.user.name, res

close_merge_request = (mr_id, project, message, res) ->
  res.send message
  return gitlab.projects(project)
    .merge_requests(mr_id)
    .put { state_event: "close" }, (err, response, mr) ->
      if err? or response.statusCode != 200
        return res.send "I was trying to close my own merge request #" + mr_id + " but it failed. You have to debug this yourself"


tag_repo_for_deployment = (branch, project, environment, name, res) ->
  now = new Date()
  gitlab.projects(project)
    .repository()
    .tags()
    .post {
      tag_name: environment + "/" + now.toISOString().replace(/:/g, "-")
      ref: branch
      message: "Tagging for deployment by " + name + "."
      release_description: "This is a " + environment + " deployment."
      }, (err, response, tags) ->
      if err? or response.statusCode != 201
        return res.send "I couldn't tag the branch correctly. You can try again or debug me, up to you."
      res.send "This branch has been tagged successfully for deployment."
  
