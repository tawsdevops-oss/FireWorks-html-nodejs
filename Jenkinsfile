pipeline {
    agent any

    parameters {

        choice(name: 'Choice_ENV', choices: ['development','main','stage'], description: 'Deployment Environment Branches')

    }
    
    stages {
        stage('CleanUP') {
            steps {
                 bat """
                    cleanWs()
                 """
            }
        }
        stage('Git Clone or SCM') {
            steps {
                 bat """
                echo Selected Branch: %Choice_ENV%
                git clone -b %Choice_ENV% https://github.com/tawsdevops-oss/FireWorks-html-nodejs.git
                """
            }
        }
    }
}

