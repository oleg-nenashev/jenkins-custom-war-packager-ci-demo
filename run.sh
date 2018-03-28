#!/usr/bin/env bash
JENKINS_HOME=$(pwd)/work java -jar target/custom-war-packager-maven-plugin/output/target/jenkins-war-1.0-artifact-manager-s3-SNAPSHOT.war --httpPort=8080 --prefix=/jenkins

