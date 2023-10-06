
node('linux')
{
  stage ('Poll') {
               // Poll from upstream:
               checkout([
                       $class: 'GitSCM',
                       branches: [[name: '*/branch-1.4']],
                       doGenerateSubmoduleConfigurations: false,
                       extensions: [],
                       userRemoteConfigs: [[url: 'git://git.savannah.gnu.org/m4.git']]])

                // Poll for local changes
                checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/main']],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [],
                        userRemoteConfigs: [[url: 'https://github.com/ZOSOpenTools/m4port.git']]])
  }

  stage('Build') {
    build job: 'Port-Pipeline', parameters: [string(name: 'PORT_GITHUB_REPO', value: 'https://github.com/ZOSOpenTools/m4port.git'), 
    string(name: 'BUILD_LINE', value: 'DEV')]
  }
}

