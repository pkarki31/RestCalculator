#!/usr/bin/env groovy

@Library("com.optum.jenkins.pipeline.library@v0.2.2") _

pipeline {

    agent none

    options {
        buildDiscarder(logRotator(daysToKeepStr: '5', numToKeepStr: '15', artifactNumToKeepStr: '15'))
    }

    environment {

        DEVOPS_METRICS_ENABLED = 'false'

        // Email to -- TO DO - Required to add DL
        EMAIL_TO = "karki_pankaj@optum.com"
        DEPLOYMENT_APPROVERS = ""

        //CREDENTIALS
        ARTIFACTORY_CREDENTIALS_ID = 'artifactory'
        OSE_CREDENTIALS_ID = 'ftm-service-account'
        GITHUB_SONAR_ID = 'ftm_sonar_Id'

        //Docker
        DTR_CREDENTIALS_ID = 'ftm-service-account'
        DTR_ORG = "rqnsftm"
        DTR_IMG_REPO = "demo-pkarki10"
        DTR_HOST = 'docker.repo1.uhc.com'
        DTR_PATH = "${DTR_HOST}/${DTR_ORG}/${DTR_IMG_REPO}"

        //Common Setting for All Environments
        OSE_APP = "demo-pkarki10"

        //Open Shift Origin - Dev
        OSO_CORE_CTC_URL = "https://origin-ctc-core-nonprod.optum.com"
        OSO_PROJECT_DEV = "ftm-dev"

        //Open Shift Origin - test
        OSO_PROJECT_TEST = "ftm-test"

        //Open Shift Origin - Uat
        OSO_PROJECT_UAT = "ftm-uat"

        //Open Shift Origin - Stage
        OSO_DMZ_ELR_URL = "https://origin-elr-dmz.optum.com"
        OSO_DMZ_CTC_URL = "https://origin-ctc-dmz.optum.com"
        OSO_PROJECT_STAGE = "ftm-stg"
        OSO_PROJECT_STAGE3 = "ftm-demo"

        //Open Shift OCP - Perf
        OCP_DMZ_CTC_URL = "https://ocp-ctc-dmz-nonprod.optum.com"
        OCP_DMZ_ELR_URL = "https://ocp-elr-dmz-nonprod.optum.com"
        OCP_PROJECT_STAGE = "ftm-perf"
        ENVIRONMENT_CONFIG_FILE = "env-config.yml"

        //Open Shift Origin - Production
        OSO_DMZ_ELR_URL_PROD = "https://ocp-elr-dmz.optum.com"
        OSO_DMZ_CTC_URL_PROD = "https://ocp-ctc-dmz.optum.com"
        OSO_PROJECT_PROD = "occ-prod"

        SN_TICKET = 'CHG0813624'
        SN_USER = 'id-for-servicenow'
    }

    stages {

        stage('Build and sonar') {
            agent { label 'docker-maven-slave' }
            steps {
                command '''
                            cd src/main/resources/
                            echo "build.version=$BUILD_NUMBER" > version.properties
                            echo "build.time=$BUILD_TIMESTAMP" >> version.properties
                            echo "build.git.hash=$GIT_COMMIT" >> version.properties
                            echo "build.git.branch=$GIT_BRANCH" >> version.properties
                        '''
                glMavenBuild additionalProps: ['ci.env': '']
             //   glSonarMavenScan productName: "RQNS_FTM_Field_Tool_Modernization", gitUserCredentialsId: "${env.GITHUB_SONAR_ID}"
                stash includes: 'target/*.jar', name: 'web-package'
            }
        }

        /*
        stage('Deploy App to Dev') {
            when { expression { env.BRANCH_NAME == 'master' } }
            agent { label 'docker-maven-slave' }
            steps {
                unstash 'web-package'
                withEnv(['ENVTYPE=dev']) {

                    script {
                        createDockerBuildArgs("${ENVTYPE}")
                    }
                    dockerImageBuildPush()

                }
                dockerTagPushImageLocal("dev")
                openshiftDeployImageLocal("dev", "${OSO_CORE_CTC_URL}", "${OSO_PROJECT_DEV}")
            }
        }

        */

        stage('Deploy App to UAT') {
            when { expression { env.BRANCH_NAME == 'master' } }
            agent { label 'docker-maven-slave' }
            steps {
                unstash 'web-package'
                withEnv(['ENVTYPE=uat']) {

                    script {
                        createDockerBuildArgs("${ENVTYPE}")
                    }
                    dockerImageBuildPush()

                }
                dockerTagPushImageLocal("dev")
                openshiftDeployImageLocal("dev", "${OSO_CORE_CTC_URL}", "${OSO_PROJECT_UAT}")
            }
        }

        /*
        stage('Test deployment Approval') {
            steps {
                emailext body: "Approval URL: ${BUILD_URL}input/",
                        subject: "$JOB_NAME - Test Deployment Approval",
                        to: "${EMAIL_TO}"
                glApproval message: 'Approve TEST deployment?', unit: 'MINUTES', time: 45, defaultValue: 'Enter approval comments', submitter: 'FTM_STAGE_DEPLOY'

            }

        }
        stage('Deploy App to TEST') {
            when { expression { env.BRANCH_NAME == 'master' } }
            agent { label 'docker-maven-slave' }
            steps {
                unstash 'web-package'
                withEnv(['ENVTYPE=test']) {

                    script {
                        createDockerBuildArgs("${ENVTYPE}")
                    }
                    dockerImageBuildPush()

                }
                dockerTagPushImageLocal("test")
                openshiftDeployImageLocal("test", "${OSO_CORE_CTC_URL}", "${OSO_PROJECT_TEST}")
            }
        }

        stage('UAT deployment Approval') {

            steps {
                emailext body: "Approval URL: ${BUILD_URL}input/",
                        subject: "$JOB_NAME - Uat Deployment Approval",
                        to: "${EMAIL_TO}"
                glApproval message: 'Approve UAT deployment?', unit: 'MINUTES', time: 45, defaultValue: 'Enter approval comments', submitter: 'FTM_STAGE_DEPLOY'

            }

        }

        stage('Deploy App to UAT') {
            when { expression { env.BRANCH_NAME == 'master' } }
            agent { label 'docker-maven-slave' }
            steps {

                unstash 'web-package'
                withEnv(['ENVTYPE=uat']) {

                    script {
                        createDockerBuildArgs("${ENVTYPE}")
                    }
                    dockerImageBuildPush()

                }
                dockerTagPushImageLocal("uat")
                openshiftDeployImageLocal("uat", "${OSO_CORE_CTC_URL}", "${OSO_PROJECT_UAT}")
            }
        }
        stage('Stage deployment Approval') {

            steps {
                emailext body: "Approval URL: ${BUILD_URL}input/",
                        subject: "$JOB_NAME - Stage Deployment Approval",
                        to: "${EMAIL_TO}"
                glApproval message: 'Approve STAGE deployment?', unit: 'MINUTES', time: 45, defaultValue: 'Enter approval comments', submitter: 'FTM_STAGE_DEPLOY'
            }
        }

        stage('Deploy App to STAGE') {
            when { expression { env.BRANCH_NAME == 'master' } }
            agent { label 'docker-maven-slave' }
            steps {
                unstash 'web-package'
                withEnv(['ENVTYPE=stage']) {

                    script {
                        createDockerBuildArgs("${ENVTYPE}")
                    }
                    dockerImageBuildPush()

                }
                dockerTagPushImageLocal("stage")
                openshiftDeployImageLocal("stage", "${OSO_DMZ_CTC_URL}", "${OSO_PROJECT_STAGE}")
            }
        }

        stage('Stage3 deployment Approval') {

            steps {
                emailext body: "Approval URL: ${BUILD_URL}input/",
                        subject: "$JOB_NAME - Stage3 Deployment Approval",
                        to: "${EMAIL_TO}"
                glApproval message: 'Approve STAGE3 deployment?', unit: 'MINUTES', time: 45, defaultValue: 'Enter approval comments', submitter: 'FTM_STAGE_DEPLOY'
            }
        }

        stage('Deploy App to STAGE3') {
            when { expression { env.BRANCH_NAME == 'master' } }
            agent { label 'docker-maven-slave' }
            steps {
                unstash 'web-package'
                withEnv(['ENVTYPE=stage3']) {

                    script {
                        createDockerBuildArgs("${ENVTYPE}")
                    }
                    dockerImageBuildPush()

                }
                dockerTagPushImageLocal("stage3")
                openshiftDeployImageLocal("stage3", "${OSO_CORE_CTC_URL}", "${OSO_PROJECT_STAGE3}")
            }
        }
        stage('Perf deployment Approval') {
            steps {
                emailext body: "Approval URL: ${BUILD_URL}input/",
                        subject: "$JOB_NAME - Perf Deployment Approval",
                        to: "${EMAIL_TO}"
                glApproval message: 'Approve Perf deployment?', unit: 'MINUTES', time: 45, defaultValue: 'Enter approval comments', submitter: 'FTM_STAGE_DEPLOY'

            }

        }

        stage('Deploy App to PERF') {
            when { expression { env.BRANCH_NAME == 'master' } }
            agent { label 'docker-maven-slave' }
            steps {
                unstash 'web-package'
                withEnv(['ENVTYPE=perf']) {

                    script {
                        createDockerBuildArgs("${ENVTYPE}")
                    }
                    dockerImageBuildPush()

                }
                dockerTagPushImageLocal("perf")
                openshiftDeployImageLocal("perf", "${OCP_DMZ_CTC_URL}", "${OCP_PROJECT_STAGE}")
                openshiftDeployImageLocal("perf", "${OCP_DMZ_ELR_URL}", "${OCP_PROJECT_STAGE}")
            }
        }

        stage('Production Deployment Approval 1') {
            steps {
                emailext body: "Approval URL: ${BUILD_URL}input/",
                        subject: "$JOB_NAME - Production Deployment Approval - Approver 1",
                        to: "${env.EMAIL_TO}"
                glApproval message: 'Approve Plexus PROD deployment? Stage 1', submitter: 'FTM_PROD_DEPLOY', displayTicket: true, duplicateApproverCheck: true
            }
        }
        stage('Production Deployment Approval 2') {
            steps {
                emailext body: "Approval URL: ${BUILD_URL}input/",
                        subject: "$JOB_NAME - Production Deployment Approval - Approver 2",
                        to: "${env.EMAIL_TO}"
                glApproval message: 'Approve Plexus PROD deployment? Stage 2', submitter: 'FTM_PROD_DEPLOY', displayTicket: true, duplicateApproverCheck: true
            }
        }

        stage('Deploy App to Prod') {
            when { expression { env.BRANCH_NAME == 'release_3.0' } }
            agent { label 'docker-maven-slave' }
            steps {
                unstash 'web-package'
                withEnv(['ENVTYPE=prod']) {

                    script {
                        createDockerBuildArgs("${ENVTYPE}")
                    }
                    dockerImageBuildPush()

                }
                dockerTagPushImageLocal("prod")
                openshiftDeployImageLocal("prod", "${OSO_DMZ_CTC_URL_PROD}", "${OSO_PROJECT_PROD}")
                openshiftDeployImageLocal("prod", "${OSO_DMZ_ELR_URL_PROD}", "${OSO_PROJECT_PROD}")
            }
        }
        */
    }

    post {
        always {

            echo 'This will always run'
            emailext body: "Build URL: ${BUILD_URL}",
                    subject: "$currentBuild.currentResult - $JOB_NAME",
                    to: "${EMAIL_TO}"
        }
        success {
            echo 'This will run only if successful'
        }
        failure {
            echo 'This will run only if failed'
        }
        unstable {
            echo 'This will run only if the run was marked as unstable'
        }
        changed {
            echo 'This will run only if the state of the Pipeline has changed'
            echo 'For example, if the Pipeline was previously failing but is now successful'
        }
    }
}

def dockerImageBuildPush() {
    glDockerImageBuildPush tag: "${DTR_PATH}:${BUILD_NUMBER}", repository: "${DTR_IMG_REPO}", namespace: "${DTR_ORG}", dockerCredentialsId: "$env.DTR_CREDENTIALS_ID", extraBuildOptions: ("$env.DOCKERBUILDOPTIONS" ?: "") + " -f Dockerfile", dockerHost: "${DTR_HOST}"
}

def dockerTagPushImageLocal(targetEnv) {
    glDockerImagePull tag: "${DTR_PATH}:${BUILD_NUMBER}", dockerCredentialsId: "$env.DTR_CREDENTIALS_ID", dockerHost: "${DTR_HOST}"
    glDockerImageTag sourceTag: "${DTR_PATH}:${BUILD_NUMBER}", destTag: "${DTR_PATH}:" + targetEnv, dockerHost: "${DTR_HOST}"
    glDockerImagePush tag: "${DTR_PATH}:" + targetEnv, dockerCredentialsId: "$env.DTR_CREDENTIALS_ID", dockerHost: "${DTR_HOST}"
}

def openshiftDeployImageLocal(targetEnv, oseServer, oseProject) {
    glOpenshiftDeploy credentials: "$env.OSE_CREDENTIALS_ID", ocpUrl: oseServer, project: oseProject, serviceName: "${OSE_APP}", dockerImage: "${DTR_PATH}:" + targetEnv, port: '8080', wait: "true"
}

def createDockerBuildArgs(envType) {
    def envConfig = readYaml file: "${ENVIRONMENT_CONFIG_FILE}"
    def dockerBuildOptions = ""
    dockerBuildOptions += " --label source.git.commit='" + env.GIT_COMMIT + "'"
    dockerBuildOptions += " --label source.git.url='" + env.GIT_URL + "'"
    dockerBuildOptions += " --label source.git.branch='" + env.BRANCH_NAME + "'"
    dockerBuildOptions += " --build-arg SPRING_PROFILES_ACTIVE=" + envType
    dockerBuildOptions += " --build-arg ENV_PROFILES_ACTIVE=" + envType
    if (envType == 'dev') {
        dockerBuildOptions += " --build-arg APPLICATIONINSIGHTS_CONNECTION_STRING=" + envConfig.APPLICATIONINSIGHTS_DEV_KEY
        env.DOCKERBUILDOPTIONS = dockerBuildOptions
        echo env.DOCKERBUILDOPTIONS
    }
    if (envType == 'test') {
        dockerBuildOptions += " --build-arg APPLICATIONINSIGHTS_CONNECTION_STRING=" + envConfig.APPLICATIONINSIGHTS_TEST_KEY
        env.DOCKERBUILDOPTIONS = dockerBuildOptions
        echo env.DOCKERBUILDOPTIONS
    }
    if (envType == 'stage') {
        dockerBuildOptions += " --build-arg APPLICATIONINSIGHTS_CONNECTION_STRING=" + envConfig.APPLICATIONINSIGHTS_STAGE_KEY
        env.DOCKERBUILDOPTIONS = dockerBuildOptions
        echo env.DOCKERBUILDOPTIONS
    }
    if (envType == 'stage3') {
        dockerBuildOptions += " --build-arg APPLICATIONINSIGHTS_CONNECTION_STRING=" + envConfig.APPLICATIONINSIGHTS_STAGE_KEY
        env.DOCKERBUILDOPTIONS = dockerBuildOptions
        echo env.DOCKERBUILDOPTIONS
    }
    if (envType == 'prod') {
        dockerBuildOptions += " --build-arg APPLICATIONINSIGHTS_CONNECTION_STRING=" + envConfig.APPLICATIONINSIGHTS_PROD_KEY
        env.DOCKERBUILDOPTIONS = dockerBuildOptions
        echo env.DOCKERBUILDOPTIONS
    }

}
