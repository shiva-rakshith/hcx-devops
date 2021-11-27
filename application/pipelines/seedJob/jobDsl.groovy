// Ref source code / examples: https://github.com/jenkinsci/job-dsl-plugin/wiki/Tutorial---Using-the-Jenkins-Job-DSL
// Ref groovy code syntax: https://riptutorial.com/groovy/example/18003/iterate-over-a-collection
// Ref jobDSL doc: http://your_jenkins_ip:8080/plugin/job-dsl/api-viewer/index.html
String deployFolder = "deploy"
String provisionFolder = "provision"
String buildFolder = "build"
String githubCredID = "github-cred"
String githubDefaultBranch = "main"

def rootFolders = [
    deployFolder,
    provisionFolder,
    buildFolder
]
def environments = [
    "dev"
]
def provisionJobs = [
    "kafka",
    "elasticsearch"
]
def deploymentJobs = [
    "hcx-api"
]
def buildJobs = [
    "hcx-api": [
        "repo": "https://github.com/rjshrjndrn/hcx-platform",
        "scriptPath": "hcx-apis/Jenkinsfile"
    ]
]

buildJob = {
        jobName,repo,jenkinsFilePath ->
        pipelineJob("$buildFolder/$jobName") {
          definition {
            cpsScm {
              scm {
                git {
                  remote {
                    url("$repo")
                  }
                  branch("*/main")
                }
              }
              lightweight()
              scriptPath("$jenkinsFilePath")
            }
          }
        }
}

// Crating root folders
rootFolders.each {
    rootFolder ->
    // If no variable defined, default will be `it`
    // But that variable has some issues with the folder() method
    // If used $it, some random string created as folder name
    println "$rootFolder"
    folder("$rootFolder") {
        displayName("$rootFolder")
        description("$rootFolder")
    }
}

// Creating Deployment Folders
environments.each {
    env ->
    folder("$deployFolder/$env") {
        description("Folder for $env")
    }
    folder("$provisionFolder/$env") {
        description("Folder for $env")
    }
}

// Creating build jobs
buildJobs.each {
    jobName ->
    println(jobName)
    buildJob(jobName.key, buildJobs[jobName.key].repo, buildJobs[jobName.key].scriptPath)
}

// Creating provision jobs
provisionJobs.each {
    provisionJobName ->
    environments.each {
        env ->
        pipelineJob("$provisionFolder/$env/$provisionJobName") {
          definition {
            cpsScm {
              scm {
                git {
                  remote {
                    url('https://github.com/rjshrjndrn/hcx-devops')
                    credentials("github-cred")
                  }
                  branch("*/${githubDefaultBranch}")
                }
              }
              lightweight()
              scriptPath("application/pipelines/provision/${provisionJobName}/Jenkinsfile")
            }
          }
        }
    }
}

// Creating deployment jobs
deploymentJobs.each {
    deployJobName ->
    environments.each {
        env ->
        pipelineJob("$deployFolder/$env/$deployJobName") {
          definition {
            cpsScm {
              scm {
                git {
                  remote {
                    url('https://github.com/rjshrjndrn/hcx-devops')
                    credentials("github-cred")
                  }
                  branch("*/${githubDefaultBranch}")
                }
              }
              lightweight()
              scriptPath("application/pipelines/deploy/${deployJobName}/Jenkinsfile")
            }
          }
        }
    }
}
