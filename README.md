# henk52-jenkins
Jenkins master and slave installation.

RPM source: https://wiki.jenkins-ci.org/display/JENKINS/Installing+Jenkins+on+Red+Hat+distributions

Create a master instance
puppet apply master_install.pp
copy the public key to the slave_install.pp
copy in all the .hpi plugins, either through wget from jenkins or from a repo.

Create a slave instance
puppet apply slave_install.pp

First

  Manage Jenkins ->  Manage Credentials -> 
    	Private Key: From the Jenkins master ~/.ssh 

connect to the jenkins master web server on 8080

Add a slave:
  Manage Jenkins -> Manage Nodes -> New Node
    Select 'Dumb slave'.
    
      Remote root directory: /var/lib/jenkins
      Host: IP address or hostname of the slave.
