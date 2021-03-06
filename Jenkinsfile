#!/usr/bin/groovy

@Library(['github.com/indigo-dc/jenkins-pipeline-library@1.2.3']) _

pipeline {
    agent {
        label 'docker-build'
    }

    environment {
        dockerhub_repo = "deephdc/deep-oc-firsttest"
        base_cpu_tag = "9.1-cudnn7-devel-ubuntu16.04"
        base_gpu_tag = "9.1-cudnn7-devel-ubuntu16.04"
    }

    stages {
        stage('Docker image building') {
            when {
                anyOf {
                   branch 'master'
                   branch 'test'
                   buildingTag()
               }
            }
            steps{
                checkout scm
                script {
                    // build different tags
                    id = "${env.dockerhub_repo}"

                    if (env.BRANCH_NAME == 'master') {
                       // CPU (aka latest, i.e. default)
                       id_cpu = DockerBuild(id,
                                            tag: ['latest', 'cpu'], 
                                            build_args: ["tag=${env.base_cpu_tag}",
                                                         "branch=master"])

                       // GPU
                       id_gpu = DockerBuild(id,
                                            tag: ['gpu'], 
                                            build_args: ["tag=${env.base_gpu_tag}",
                                                         "branch=master"])
                    }

                    if (env.BRANCH_NAME == 'test') {
                       // CPU
                       id_cpu = DockerBuild(id,
                                            tag: ['test', 'cpu-test'], 
                                            build_args: ["tag=${env.base_cpu_tag}",
                                                         "branch=test"])

                       // GPU
                       id_gpu = DockerBuild(id,
                                            tag: ['gpu-test'], 
                                            build_args: ["tag=${env.base_gpu_tag}",
                                                         "branch=test"])
                    }

                }
            }
            post {
                failure {
                    DockerClean()
                }
            }
        }



        stage('Docker Hub delivery') {
            when {
                anyOf {
                   branch 'master'
                   branch 'test'
                   buildingTag()
               }
            }
            steps{
                script {
                    DockerPush(id_cpu)
                    DockerPush(id_gpu)
                }
            }
            post {
                failure {
                    DockerClean()
                }
                always {
                    cleanWs()
                }
            }
        }
    }
}
