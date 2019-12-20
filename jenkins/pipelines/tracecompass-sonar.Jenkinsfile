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
            yamlFile 'jenkins/pod-templates/tracecompass-sonar-pod.yaml'
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
                checkout([$class: 'GitSCM', branches: [[name: '$GERRIT_BRANCH_NAME']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'BuildChooserSetting', buildChooser: [$class: 'GerritTriggerBuildChooser']]], submoduleCfg: [], userRemoteConfigs: [[refspec: '$GERRIT_REFSPEC', url: '$GERRIT_REPOSITORY_URL']]])
            }
        }
        stage('Build') {
            steps {
                container('tracecompass') {
                    sh 'mvn clean install -B -Pctf-grammar -Pbuild-rcp -Dmaven.test.error.ignore=true -Dmaven.test.failure.ignore=true -Dmaven.repo.local=/home/jenkins/.m2/repository --settings /home/jenkins/.m2/settings.xml ${MAVEN_ARGS}'
                }
            }
        }
        stage('Sonar') {
            steps {
                container('tracecompass') {
                    withSonarQubeEnv('Eclipse Sonar') {
                        sh 'mvn -B -Djacoco.dataFile=../../target/jacoco.exec jacoco:report sonar:sonar -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.jdbc.url=$SONAR_JDBC_URL -Dsonar.jdbc.username=$SONAR_JDBC_USERNAME -Dsonar.jdbc.password=$SONAR_JDBC_PASSWORD'
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
