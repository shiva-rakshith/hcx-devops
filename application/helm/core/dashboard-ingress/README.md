### SSL

We're not using ingress controller, because of that we can't use certmanager directly.
Below are the steps to create ssl certificate from Let's Encrypt.

1. Map the domain name to dns
2. Update the proper values in dummy/certbot-autoupdater.yaml 
   ```
   export DOMAIN_NAME="<new.domain.name>"
   export NAMESPACE="<your app namespace>"
   sed -i "s/dev-hcx.swasth.app/${DOMAIN_NAME}/g" dummy/certbot-autoupdater.yaml
   ```
3. Apply the configuration 
   ```
   kubectl apply -f dummy/certbot-autoupdater.yaml -n ${NAMESPACE}
   ```
4. The updater will run at 16:00 on 6th every month UTC time. To get the certificate now,
  1. Check the current utc time, and say for example its 14:01
  2. Update the cron for 14:03 using  
    ```
    kubectl patch cronjob certbot -n ${NAMESPACE} --patch '{"spec":{"schedule": "03 14 * * *"}}'
    ```
  3. Wait for the cron to create pods 
    ```
    # Check the job status
    kubectl get cronjob -n ${NAMESPACE} -Aw
    
    # Once the job status changes, do the following to check the logs
    kubectl logs -n ${NAMESPACE} -l app=certbot
    ```
  4. Once that's done, check the ssl using 
     ```
     curl https://${DOMAIN_NAME}
     ```
  5. After successful validation, change the cronjob to monthly
    ```
    kubectl apply -f dummy/certbot-autoupdater.yaml -n ${NAMESPACE}
    ```
