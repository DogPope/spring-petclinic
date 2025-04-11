[Jenkins, AWS, Docker, K8s](https://medium.com/@bubu.tripathy/building-a-ci-cd-pipeline-for-a-spring-boot-application-763a2dec1ac4)
^ Useful link for deploying with Jenkins.
Java had to be refactored to use Java 17 instead of 21. Oh, well.


AWS command for EKS setup. `aws eks create-cluster --name your-eks-cluster --role-arn arn:aws:iam::123456789012:role/eks-cluster-role --resources-vpc-config subnetIds=subnet-xxxxxxxxxxxxxxxxx,securityGroupIds=sg-xxxxxxxxxxxxxxxxx`
^ EKS = Kubernetes. In case you were wondering.

You're right, the step you've provided should generally execute the same way within a Jenkins Pipeline as it would on the command line, assuming the environment is set up correctly. The fact that it loops infinitely within the pipeline but works fine from the command line suggests an environmental difference or a subtle interaction with Jenkins.

Here are several potential causes for this infinite looping when running your SonarQube Docker job through a Jenkins Pipeline:

1. Environment Variables and Context:

    Missing or Incorrect Environment Variables: The withSonarQubeEnv('SonarQube') step is crucial for setting up the necessary environment variables (like SONAR_HOST_URL, SONAR_TOKEN, etc.) that your gradlew sonar command relies on to communicate with the SonarQube server. If these variables are not being correctly injected or are missing within the Jenkins Pipeline execution environment, your Gradle build might be failing to connect to SonarQube and retrying indefinitely.
    Different Working Directory: While your command might work from your local command line where you are likely in the project root, the Jenkins Pipeline might be executing the powershell './gradlew sonar' command from a different working directory. Ensure that the relative path ./gradlew is valid within the Jenkins workspace. It's often safer to use the dir() step to explicitly set the working directory before executing the SonarQube analysis.
    User Permissions: The Jenkins agent might be running with different user permissions than your local user. This could potentially affect access to resources or the execution of the Gradle command.

2. Docker Interaction within Jenkins:

    Docker Daemon Access: If your gradlew sonar script internally tries to interact with the Docker daemon (e.g., to pull or run the SonarQube Docker container itself, although this is less likely given you're using withSonarQubeEnv), there might be permission issues or configuration differences in how the Jenkins agent can access the Docker daemon compared to your local machine.
    Resource Constraints: The Jenkins agent might have different resource limitations (CPU, memory) compared to your local machine. While less likely to cause an infinite loop directly, it could lead to the SonarQube analysis failing or hanging in a way that your Gradle build retries indefinitely.

3. Gradle Configuration and SonarQube Plugin:

    Incorrect SonarQube Gradle Plugin Configuration: Double-check your build.gradle file for the SonarQube plugin configuration. Ensure the sonar.host.url and sonar.login properties are either being correctly picked up from the environment variables set by withSonarQubeEnv or are explicitly configured correctly. If these are wrong or missing, the SonarQube analysis might fail and trigger retries.
    Plugin Version Incompatibilities: While less likely to cause an infinite loop, ensure the versions of your Gradle, the SonarQube Gradle plugin, and the SonarQube server are compatible.

4. Jenkins Pipeline Specific Issues:

    Node Allocation and Agent Configuration: If your Jenkins setup uses multiple agents, the agent running the pipeline might have a different configuration or access to resources than your local machine.
    Plugin Interactions: While less common, other Jenkins plugins installed in your environment could potentially interfere with the execution of the SonarQube analysis step.

5. Script Logic (Less Likely in this simple example):

    While your provided snippet is straightforward, if the gradlew sonar script itself contains any internal looping or retry mechanisms based on the SonarQube analysis result, and if the analysis is consistently failing in the Jenkins environment, this could lead to the observed behavior.

Troubleshooting Steps:

    Verify Environment Variables:
        Within your Jenkins Pipeline, add a step to print the environment variables, especially those related to SonarQube, to ensure they are being set correctly by withSonarQubeEnv.
    Groovy

stage('Debug Environment') {
    steps {
        script {
            env.each { key, value ->
                println "${key}=${value}"
            }
        }
    }
}

Explicitly Set Working Directory:

    Wrap your powershell step with dir() to ensure you are in the correct project directory.

Groovy

    stage('Sonar Analysis') {
        steps {
            dir("${WORKSPACE}") { // Or the specific subdirectory if needed
                withSonarQubeEnv('SonarQube') {
                    powershell './gradlew sonar'
                }
            }
        }
    }

    Examine Jenkins Console Output:
        Carefully review the Jenkins console output for the SonarQube analysis stage. Look for any error messages, connection issues, or repeated attempts to connect to the SonarQube server. This might provide clues about why it's looping.

    Simplify the Pipeline:
        Temporarily simplify your Jenkins Pipeline to only include the SonarQube analysis step to isolate the issue.

    Try a Basic Gradle Command:
        Within the withSonarQubeEnv block, try running a simple Gradle command like gradle --version to see if Gradle itself is executing correctly within the Jenkins environment.

    Check SonarQube Server Logs:
        Examine the SonarQube server logs for any incoming connection attempts or errors related to the analysis being triggered by Jenkins.

    Compare Jenkins Agent Configuration:
        If you have access to the Jenkins agent configuration, compare it to your local development environment, especially regarding Docker access and resource limits.

    Consider Absolute Paths (Less Recommended):
        As a temporary debugging step, try using the absolute path to your gradlew executable to rule out any path resolution issues. However, relying on absolute paths is generally not recommended for portability.

By systematically checking these potential causes and examining the Jenkins console output, you should be able to narrow down the reason why your SonarQube Docker job is infinitely looping in the Jenkins Pipeline but works fine from the command line. The most likely culprit is a difference in the environment variables or the working directory between the two execution contexts.