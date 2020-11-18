pipeline {
  agent {
    node {
      label 'generic-docker-build'
      customWorkspace "workspace/${env.JOB_NAME}/${env.BUILD_NUMBER}"
    }
  }
  options {
    timeout(time: 10, unit: 'MINUTES')
    timestamps()
  }
  parameters {
    string(name: 'TARGET_PREFIX',
      defaultValue: 'tacodev',
      description: 'Prefix for the target docker repository.')
    string(name: 'REPOS',
      defaultValue: 'https://tde.sktelecom.com/stash/scm/oreotools/taco-helm.git https://tde.sktelecom.com/stash/scm/oreotools/taco-addons.git',
      description: 'The comma-seperated list of repositories for this image sync job')
    string(name: 'WORK_DIR',
      defaultValue: '/tmp/image_sync_temp',
      description: 'Working directory for sync jab. DO NOT MODIFY without any intention.')      
  }

  stages {
    stage('Clone') {
      steps {
        container('git-client') {
          notifyStarted()
          script {
            sh """
              mkdir ${params.WORK_DIR}
              cd ${params.WORK_DIR}
              for repo in `echo ${params.REPOS}`
              do
                  git clone \$repo
              done
            """
          }
        }
      }
    }
    stage('Sync') {
      steps {
        container('client') {
          notifyStarted()
          script {
            sh """
              echo "docker login as tacouser"
              docker login -u tacouser -p taco1130@

              for dname in `ls ${params.WORK_DIR}`
              do
                  echo "moving to " ${params.WORK_DIR}/\$dname
                  cd ${params.WORK_DIR}/$dname
                  for cname in `ls`
                  do
                      echo ">>> now in \$cname"
                      for iname in `helm template \$cname | grep image: | awk -F image:\\  '{print \$2}'`
                      do
                          siname=\${iname//\"}
                          tiname=${params.WORK_DIR}/\$(echo \$siname | awk -F \\/ '{print \$NF}')
                          echo "sync \$siname to \$tiname"
                          echo sudo docker pull \$siname
                          echo sudo docker tag \$siname \$tiname
                          echo sudo docker push \$tiname
                      done
                  done
              done
            """
          }
        }
      }
    }
  }

  post {
    success {
      script {
        println("Skipping notification..")
      }
    }
    failure {
      notifyCompleted(false)
    }
  }
}
