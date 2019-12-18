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
            yamlFile 'jenkins/pod-templates/tracecompass-pod.yaml'
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
        MAVEN_WORKSPACE_SCRIPTS="../scripts"
        WORKSPACE_SCRIPTS="${WORKSPACE}/.scripts/"
        SITE_PATH="common/org.eclipse.tracecompass.incubator.releng-site/target/repository/"
        RCP_PATH="rcp/org.eclipse.tracecompass.incubator.rcp.product/target/products/"
        RCP_SITE_PATH="rcp/org.eclipse.tracecompass.incubator.rcp.product/target/repository/"
        RCP_PATTERN="trace-compass-*"
        SERVER_RCP_PATH="trace-server/org.eclipse.tracecompass.incubator.trace.server.product/target/products/"
        SERVER_RCP_SITE_PATH="trace-server/org.eclipse.tracecompass.incubator.trace.server.product/target/repository/"
        SERVER_RCP_PATTERN="trace-compass-server*"
    }
    stages {
        stage('Checkout') {
            steps {
                container('tracecompass') {
                    sh 'mkdir -p ${MAVEN_WORKSPACE_SCRIPTS}'
                    sh 'cp scripts/deploy-rcp.sh ${MAVEN_WORKSPACE_SCRIPTS}'
                    sh 'cp scripts/deploy-update-site.sh ${MAVEN_WORKSPACE_SCRIPTS}'
                    sh 'cp scripts/deploy-doc.sh ${MAVEN_WORKSPACE_SCRIPTS}'
                    checkout([$class: 'GitSCM', branches: [[name: '$GERRIT_BRANCH_NAME']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'BuildChooserSetting', buildChooser: [$class: 'GerritTriggerBuildChooser']]], submoduleCfg: [], userRemoteConfigs: [[refspec: '$GERRIT_REFSPEC', url: '$GERRIT_REPOSITORY_URL']]])
                    sh 'mkdir -p ${WORKSPACE_SCRIPTS}'
                    sh 'cp ${MAVEN_WORKSPACE_SCRIPTS}/deploy-rcp.sh ${WORKSPACE_SCRIPTS}'
                    sh 'cp ${MAVEN_WORKSPACE_SCRIPTS}/deploy-update-site.sh ${WORKSPACE_SCRIPTS}'
                    sh 'cp ${MAVEN_WORKSPACE_SCRIPTS}/deploy-doc.sh ${WORKSPACE_SCRIPTS}'
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
                    sh 'mvn clean install -B -Pdeploy-doc -DdocDestination=${WORKSPACE}/doc/.temp -Pbuild-rcp -Dmaven.repo.local=/home/jenkins/.m2/repository --settings /home/jenkins/.m2/settings.xml ${MAVEN_ARGS}'
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
        stage('Deploy Site') {
            when {
                expression { return params.DEPLOY_SITE }
            }
            steps {
                container('jnlp') {
                    sshagent (['projects-storage.eclipse.org-bot-ssh']) {
                        sh '${WORKSPACE_SCRIPTS}/deploy-update-site.sh ${SITE_PATH} ${SITE_DESTINATION}'
                    }
                }
            }
        }
        stage('Deploy RCP') {
            when {
                expression { return params.DEPLOY_RCP }
            }
            steps {
                container('jnlp') {
                    sshagent (['projects-storage.eclipse.org-bot-ssh']) {
                        sh '${WORKSPACE_SCRIPTS}/deploy-rcp.sh ${RCP_PATH} ${RCP_DESTINATION} ${RCP_SITE_PATH} ${RCP_SITE_DESTINATION} ${RCP_PATTERN}'
                    }
                }
            }
        }
        stage('Deploy Server') {
            when {
                expression { return params.DEPLOY_RCP }
            }
            steps {
                container('jnlp') {
                    sshagent (['projects-storage.eclipse.org-bot-ssh']) {
                        sh '${WORKSPACE_SCRIPTS}/deploy-rcp.sh ${SERVER_RCP_PATH} ${SERVER_RCP_DESTINATION} ${SERVER_RCP_SITE_PATH} ${SERVER_RCP_SITE_DESTINATION} ${SERVER_RCP_PATTERN}'
                    }
                }
            }
        }
        stage('Deploy Doc') {
            when {
                expression { return params.DEPLOY_DOC }
            }
            steps {
                container('jnlp') {
                    sshagent (['projects-storage.eclipse.org-bot-ssh']) {
                       sh '${WORKSPACE_SCRIPTS}/deploy-doc.sh'
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
------------------------------------------ \n
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
