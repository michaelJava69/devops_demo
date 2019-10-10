pipeline {
    agent any
     environment {
         AWS_BIN = '/usr/local/bin/aws'
         my_stage = 'KOPS'
     }

    stages {

        stage('KOPS deploy stage') {

            environment {
                AWS_BIN = '/usr/local/bin/aws'
            }
            steps {


                  withCredentials([[
                       $class: 'AmazonWebServicesCredentialsBinding',
                       credentialsId: 'aws-key',
                       accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                       secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                   ]]) {
                        sh './kops/kops.sh'
                 }

                 echo 'Hello Kops'



            }
        }

        stage('Input') {
            steps {
                input('Do you want to proceed to build Terraform?')
            }
        }

        stage('If Proceed is clicked') {
            environment {
                AWS_BIN = '/usr/local/bin/aws'
            }
            steps {
                print('Terraform')
                 script {
                    env.my_stage = 'TERRAFORM'
                 }

                // Permission to execute
                // sh "chmod +x -R ${env.WORKSPACE}/../${env.JOB_NAME}@script"
                // Call SH
                // sh "${env.WORKSPACE}/../${env.JOB_NAME}@script/script.sh"
                 
                
                //env.WORKSPACE = pwd()

                withCredentials([[
                       $class: 'AmazonWebServicesCredentialsBinding',
                       credentialsId: 'aws-key',
                       accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                       secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                       sh '''
                            sed -i 's/"0-0-0-0--0/"aws-0-0-0-0--0/g' azuka_helm_terraform/kubernetes.tf
                            file="kubernetes.tf"

                            if [ -f $file ] ; then
                                 rm $file
                            fi
                            if [ -d data ]; then rm -Rf data; fi
                       '''
                       sh " cp -n azuka_helm_terraform/kubernetes.tf ."
                       sh " cp -Rvp azuka_helm_terraform/data ."

                       //sh 'cd azuka_helm_terraform/'
                       //sh ' chmod u+x versions-1.tf '
                       sh 'terraform init'
                       sh 'terraform 0.12upgrade -force -yes '
                       sh 'terraform apply -auto-approve'



                }
            }
        }

    }
    post {

           failure {

               script {
                   //Check for the boolean condition
                   if (env.my_stage == 'KOPS') {
                     withCredentials([[
                         $class: 'AmazonWebServicesCredentialsBinding',
                         credentialsId: 'aws-key',
                         accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                         secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                     ]]) {

                          sh './kops/delete-kops.sh'
                     }

                     } else {

                  }
               }
           }
           success {

               sh '''
                  echo 'This will run only if successful'
                  WORKING_DIR=/var/lib/jenkins/kubenetes-build/build1
                  if [ -d "$WORKING_DIR" ]; then rm -Rf $WORKING_DIR; fi
                  mkdir /var/lib/jenkins/kubenetes-build/build1
                  cp -Rvp  data /var/lib/jenkins/kubenetes-build/build1/
                  cp -Rvp  .terraform /var/lib/jenkins/kubenetes-build/build1/
                  cp   versions.tf /var/lib/jenkins/kubenetes-build/build1/
                  cp   kubernetes.tf /var/lib/jenkins/kubenetes-build/build1/
                  cp   terraform.tfstate /var/lib/jenkins/kubenetes-build/build1/
              '''
           }

     }

}
