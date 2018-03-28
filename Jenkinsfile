#!/usr/bin/env groovy

def jdk = "8"

node("docker") {
    stage("Checkout") {
        if (env.BRANCH_NAME) {
            checkout scm
        } else if ((env.BRANCH_NAME == null) && (repo)) {
            git repo
        } else {
            error 'buildPlugin must be used as part of a Multibranch Pipeline *or* a `repo` argument must be provided'
        }

        isMaven = fileExists('pom.xml')
    }

    def outputWARpattern = "target/custom-war-packager-maven-plugin/output/target/jenkins-war-1.0-artifact-manager-s3-SNAPSHOT.war"
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
        archiveArtifacts artifacts: outputWARpattern
    }

    def outputWAR = pwd() + "/" + outputWARpattern
    stage("Run ATH") {
        def fileUri = "file://" + outputWAR
        def metadataPath = pwd() + "/ath.yml"
        dir("ath") {
            runATH jenkins: fileUri, metadataFile: metadataPath
        }
    }

    stage("Run PCT") {
        def pctReportDir = pwd() + "pct_report"
        dir("pct") {
            // Should fail until https://github.com/jenkinsci/copyartifact-plugin/pull/99 or /100
            sh "docker run --rm -v maven-repo:/root/.m2 -v ${pctReportDir}/out:/pct/out -v ${outputWAR}:/pct/jenkins.war:ro -e ARTIFACT_ID=copyartifact jenkins/pct"
            //TODO: publish the report
        }
    }
}