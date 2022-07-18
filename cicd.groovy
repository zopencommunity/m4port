node('linux') 
{
        stage('Build') {
                build job: 'Port-Pipeline', parameters: [string(name: 'REPO', value: 'm4port'), string(name: 'DESCRIPTION', 'M4 is an implementation of the traditional Unix macro processor.' )]
        }
}
