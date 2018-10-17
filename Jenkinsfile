//Jenkinsfile
node {

  stage('Preparation') {
    //Installing kubectl in Jenkins agent
    sh 'curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl'
	sh 'chmod +x ./kubectl && mv kubectl /usr/local/sbin'

	//Clone git repository
	git url:'https://bitbucket.org/advatys/jenkins-pipeline.git'
  }

  stage('Integration') {
	
    withKubeConfig([credentialsId: 'jenkins-deployer-credentials', serverUrl: 'https://35.200.244.228']) {
      
      sh 'kubectl create cm nodejs-app --from-file=src/ --namespace=default -o=yaml --dry-run > deploy/cm.yaml'
      sh 'kubectl apply -f deploy/ --namespace=default'
      try{
      	//Gathering Node.js app's external IP address
      	def ip = ''
      	def count = 0
      	def countLimit = 10
      	
      	//Waiting loop for IP address provisioning
      	println("Waiting for IP address")       	
      	while(ip=='' && count<countLimit) {
      		sleep 30
      		ip = sh script: 'kubectl get svc --namespace=default -o jsonpath="{.items[?(@.metadata.name==\'nginx-reverseproxy-service\')].status.loadBalancer.ingress[*].ip}"', returnStdout: true
      		ip=ip.trim()
      		count++                                                                              
      	}
      	
		if(ip==''){
			error("Not able to get the IP address. Aborting...")
		    
		}
		else{
		            //Executing tests 
		sh "chmod +x tests/integration-tests.sh && ./tests/integration-tests.sh ${ip}"
		
		//Cleaning the integration environment
		println("Cleaning integration environment...")
		sh 'kubectl delete -f deploy --namespace=default'
        println("Integration stage finished.")   
		}                      
     
      }
      catch(Exception e) {
      	println("Integration stage failed.")
	  	println("Cleaning integration environment...")
	  	sh 'kubectl delete -f deploy --namespace=default'
      	error("Exiting...")                                     
      }

    }
  }
  stage('Production') {
    withKubeConfig([credentialsId: 'jenkins-deployer-credentials', serverUrl: 'https://35.200.244.228']) {
      
    	sh 'kubectl create cm nodejs-app --from-file=src/ --namespace=default -o=yaml --dry-run > deploy/cm.yaml'
     	sh 'kubectl apply -f deploy/ --namespace=default'
      
  
	   	//Gathering Node.js app's external IP address
      	def ip = ''
      	def count = 0
      	def countLimit = 10
      	
      	//Waiting loop for IP address provisioning
      	println("Waiting for IP address")       	
      	while(ip=='' && count<countLimit) {
      		sleep 30
      		ip = sh script: 'kubectl get svc --namespace=default -o jsonpath="{.items[?(@.metadata.name==\'nginx-reverseproxy-service\')].status.loadBalancer.ingress[*].ip}"', returnStdout: true
      		ip = ip.trim()
      		count++                                                                              
      	}
      	
		if(ip==''){
			println("Not able to get the IP address. Aborting...")
		    return
		}
		else{
		            //Executing tests 
		sh "chmod +x tests/production-tests.sh && ./tests/production-tests.sh ${ip}"     
       	}                                    
    }
  }
}
