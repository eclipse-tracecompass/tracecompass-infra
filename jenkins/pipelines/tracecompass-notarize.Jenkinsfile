/*******************************************************************************
 * Copyright (c) 2024 Ericsson.
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
            label 'tracecompass-notarize-build'
            yamlFile 'jenkins/pod-templates/tracecompass-sonar-pod.yaml'
        }
    }
    options {
        timestamps()
        timeout(time: 4, unit: 'HOURS')
        disableConcurrentBuilds()
    }
    stages {
        stage('Notarize macos RCP packages') {
            when {
                not { expression { return params.RCP_DESTINATION == null || params.RCP_DESTINATION.isEmpty() } }
            }
            steps {
                sshagent (['projects-storage.eclipse.org-bot-ssh']) {
                    sh 'scripts/macosx-notarize.sh ${RCP_DESTINATION}'
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: '*.log', allowEmptyArchive: true
                }
            }
        }
    }
}
