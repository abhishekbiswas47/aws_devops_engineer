stage('Deploy') {
    // Copy files to EC2 instance. Replace with your actual credentials and IP address
    sh 'scp -i /path/to/key.pem /path/to/your/project ubuntu@ec2-xx-xx-xx-xx.compute-1.amazonaws.com:/path/on/server'

    // Run command on EC2 instance to start the service. Replace with your actual command
    sh 'ssh -i /path/to/key.pem ubuntu@ec2-xx-xx-xx-xx.compute-1.amazonaws.com "sudo service your-service start"'
}
