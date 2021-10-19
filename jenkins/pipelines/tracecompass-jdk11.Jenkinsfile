/*******************************************************************************
 * Copyright (c) 2019, 2021 Ericsson.
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
        }
    }
    options {
        timestamps()
        timeout(time: 4, unit: 'HOURS')
        disableConcurrentBuilds()
    }
    tools {
        maven 'apache-maven-latest'
        jdk 'openjdk-jdk11-latest'
    }
    environment {
        MAVEN_OPTS="-Xms768m -Xmx4096m -XX:+UseSerialGC"
        MAVEN_WORKSPACE_SCRIPTS="../scripts"
        WORKSPACE_SCRIPTS="${WORKSPACE}/.scripts/"
        SITE_PATH="releng/org.eclipse.tracecompass.releng-site/target/repository/"
        RCP_PATH="rcp/org.eclipse.tracecompass.rcp.product/target/products/"
        RCP_SITE_PATH="rcp/org.eclipse.tracecompass.rcp.product/target/repository/"
        RCP_PATTERN="trace-compass-*"
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
        stage('Build') {
            steps {
                container('tracecompass') {
                    sh 'mkdir -p ${WORKSPACE}/doc/.temp'
                    sh 'mkdir -p ${WORKSPACE}/doc/.temp/org.eclipse.tracecompass.doc.dev'
                    sh 'mkdir -p ${WORKSPACE}/doc/.temp/org.eclipse.tracecompass.doc.user'
                    sh 'mkdir -p ${WORKSPACE}/doc/.temp/org.eclipse.tracecompass.gdbtrace.doc.user'
                    sh 'mkdir -p ${WORKSPACE}/doc/.temp/org.eclipse.tracecompass.rcp.doc.user'
                    sh 'mkdir -p ${WORKSPACE}/doc/.temp/org.eclipse.tracecompass.tmf.pcap.doc.user'
                    sh 'mvn clean install -B -Dskip-jacoco=true -Pdeploy-doc -DdocDestination=${WORKSPACE}/doc/.temp -Pctf-grammar -Pbuild-rcp -Dmaven.repo.local=/home/jenkins/.m2/repository --settings /home/jenkins/.m2/settings.xml ${MAVEN_ARGS}'
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
                sshagent (['projects-storage.eclipse.org-bot-ssh']) {
                    sh '${WORKSPACE_SCRIPTS}/deploy-update-site.sh ${SITE_PATH} ${SITE_DESTINATION}'
                }
            }
        }
        stage('Deploy RCP') {
            when {
                expression { return params.DEPLOY_RCP }
            }
            steps {
                sshagent (['projects-storage.eclipse.org-bot-ssh']) {
                    sh '${WORKSPACE_SCRIPTS}/deploy-rcp.sh ${RCP_PATH} ${RCP_DESTINATION} ${RCP_SITE_PATH} ${RCP_SITE_DESTINATION} ${RCP_PATTERN} false'
                }
            }
        }
        stage('Deploy Doc') {
            when {
                expression { return params.DEPLOY_DOC }
            }
            steps {
                sshagent (['projects-storage.eclipse.org-bot-ssh']) {
                    sh '${WORKSPACE_SCRIPTS}/deploy-doc.sh'
                }
            }
        }
    }
    post {
        failure {
            container('tracecompass') {
                emailext subject: 'Build $BUILD_STATUS: $PROJECT_NAME #$BUILD_NUMBER!',
                body: '''$CHANGES \n
------------------------------------------\n
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
