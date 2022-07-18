node('linux') 
{
        stage('Build') {
                build job: 'Port-Pipeline', parameters: [string(name: 'REPO', value: 'm4port'), string(name: 'DESCRIPTION', 'm4port' )]
        }
}
