/*******************************************************************************
 * Copyright (c) 2019 Ericsson.
 *
 * This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * which accompanies this distribution, and is available at
 * https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 *******************************************************************************/
pipeline {
    agent {
        kubernetes {
            label 'tracecompass-build'
            yamlFile 'pod-templates/tracecompass-pod.yaml'
            defaultContainer 'tracecompass'
        }
    }
    options {
        timestamps()
        timeout(time: 4, unit: 'HOURS')
        disableConcurrentBuilds()
    }
    tools {
        maven 'apache-maven-latest'
        jdk 'oracle-jdk8-latest'
    }
    environment {
        MAVEN_OPTS="-Xms768m -Xmx4096m -XX:+UseSerialGC"
    }
    stages {
        stage('Checkout') {
            steps {
            	container('tracecompass') {
                    checkout([$class: 'GitSCM', branches: [[name: '$GERRIT_BRANCH_NAME']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'BuildChooserSetting', buildChooser: [$class: 'GerritTriggerBuildChooser']]], submoduleCfg: [], userRemoteConfigs: [[refspec: '$GERRIT_REFSPEC', url: '$GERRIT_REPOSITORY_URL']]])
                }
            }
        }
        stage('Legacy') {
            when {
                expression { return params.LEGACY }
            }
            steps {
                container('tracecompass') {
                    sh 'cp -f ${WORKSPACE}/rcp/org.eclipse.tracecompass.incubator.rcp.product/legacy/tracing.product ${WORKSPACE}/rcp/org.eclipse.tracecompass.incubator.rcp.product/'
                }
            }    
        }
        stage('Build') {
            steps {
                container('tracecompass') {
                    sh 'mvn clean install -B -Pbuild-rcp -Dmaven.repo.local=/home/jenkins/.m2/repository --settings /home/jenkins/.m2/settings.xml ${MAVEN_ARGS}'
                }
            }
            post {
                always {
                    container('tracecompass') {
                        sh 'echo $ARCHIVE_ARTIFACTS'
                        junit '*/*/target/surefire-reports/*.xml'
                        archiveArtifacts artifacts: '$ARCHIVE_ARTIFACTS', excludes: '**/org.eclipse.tracecompass.common.core.log', allowEmptyArchive: true
                    }
                }
            }
        }
        stage('Deploy') {
            when {
                expression { return params.DEPLOY }
            }
            steps {
                container('jnlp') {
                    sshagent (['projects-storage.eclipse.org-bot-ssh']) {
                        sh 'ssh genie.tracecompass@projects-storage.eclipse.org mkdir -p ${RCP_DESTINATION}'
                        sh 'ssh genie.tracecompass@projects-storage.eclipse.org mkdir -p ${RCP_SITE_DESTINATION}'
                        sh 'ssh genie.tracecompass@projects-storage.eclipse.org mkdir -p ${SERVER_RCP_DESTINATION}'
                        sh 'ssh genie.tracecompass@projects-storage.eclipse.org mkdir -p ${SERVER_RCP_SITE_DESTINATION}'
                        sh 'ssh genie.tracecompass@projects-storage.eclipse.org mkdir -p ${SITE_DESTINATION}' 
                        sh 'ssh genie.tracecompass@projects-storage.eclipse.org rm -rf  ${RCP_DESTINATION}*'
                        sh 'ssh genie.tracecompass@projects-storage.eclipse.org rm -rf  ${RCP_SITE_DESTINATION}*'
                        sh 'ssh genie.tracecompass@projects-storage.eclipse.org rm -rf  ${SERVER_RCP_DESTINATION}*'
                        sh 'ssh genie.tracecompass@projects-storage.eclipse.org rm -rf  ${SERVER_RCP_SITE_DESTINATION}*'
                        sh 'ssh genie.tracecompass@projects-storage.eclipse.org rm -rf  ${SITE_DESTINATION}*'
                        sh 'scp -r ${RCP_PATH} genie.tracecompass@projects-storage.eclipse.org:${RCP_DESTINATION}'
                        sh 'scp -r ${RCP_SITE_PATH} genie.tracecompass@projects-storage.eclipse.org:${RCP_SITE_DESTINATION}'
                        sh 'scp -r ${SERVER_RCP_PATH} genie.tracecompass@projects-storage.eclipse.org:${SERVER_RCP_DESTINATION}'
                        sh 'scp -r ${SERVER_RCP_SITE_PATH} genie.tracecompass@projects-storage.eclipse.org:${SERVER_RCP_SITE_DESTINATION}'
                        sh 'scp -r ${SITE_PATH} genie.tracecompass@projects-storage.eclipse.org:${SITE_DESTINATION}'
                    }
                }
            }
        }
    }
    post {
        failure {
            container('tracecompass') {
                emailext subject: 'Build $BUILD_STATUS: $PROJECT_NAME #$BUILD_NUMBER!', 
                body: '''$CHANGES \n
------------------------------------------
Check console output at $BUILD_URL to view the results.''',
                recipientProviders: [culprits(), requestor()],
                to: '${EMAIL_RECIPIENT}'
            }
        }
        fixed {
            container('tracecompass') {
                emailext subject: 'Build is back to normal: $PROJECT_NAME #$BUILD_NUMBER!',
                body: '''Check console output at $BUILD_URL to view the results.''',
                recipientProviders: [culprits(), requestor()],
                to: '${EMAIL_RECIPIENT}'
             }
        }
    }
}