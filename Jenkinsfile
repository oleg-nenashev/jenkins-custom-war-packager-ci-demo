#!/usr/bin/env groovy

def jdk = "8"

node("docker") {
    stage("Checkout (${stageIdentifier})") {
        if (env.BRANCH_NAME) {
            checkout scm
        }
        else if ((env.BRANCH_NAME == null) && (repo)) {
            git repo
        }
        else {
            error 'buildPlugin must be used as part of a Multibranch Pipeline *or* a `repo` argument must be provided'
        }

        isMaven = fileExists('pom.xml')
    }

    stage("Build Custom WAR") {
        String jdkTool = "jdk${jdk}"
        List<String> env = [
                "JAVA_HOME=${tool jdkTool}",
                'PATH+JAVA=${JAVA_HOME}/bin',
                "PATH+MAVEN=${tool 'mvn'}/bin"
        ]

        List<String> mavenOptions = [
            '--batch-mode',
            '--errors',
            'clean',
            'install'
        ]

        command = "mvn ${mavenOptions.join(' ')}"
        withEnv(env) {
            if (isUnix()) {
                sh command
            } else {
                bat command
            }
        }
    }

    def outputWAR = "/target/custom-war-packager-maven-plugin/output/target/jenkins-war-1.0-artifact-manager-s3-SNAPSHOT.war"
    stage("Run ATH") {
        def fileUri = "file://" + pwd() + outputWAR
        def metadataPath = pwd() + "/ath.yml"
        dir("ath") {
            runATH jenkins: fileUri, metadataFile: metadataPath
        }
    }

    stage("Run PCT") {
        dir("pct") {
            // Should fail until https://github.com/jenkinsci/copyartifact-plugin/pull/99 or /100
            sh "docker run --rm -v maven-repo:/root/.m2 -v \$(pwd)/out:/pct/out -v my/jenkins.war:/pct/jenkins.war:ro -e ARTIFACT_ID=copyartifact jenkins/pct"
        }
    }
}