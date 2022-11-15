### SSL

We're not using ingress controller, because of that we can't use certmanager directly.
Below are the steps to create ssl certificate from Let's Encrypt.

1. Map the domain name to dns
2. Update the proper values in dummy/certbot-autoupdater.yaml 
   ```
   sed -i 's/dev-hcx.swasth.app/new.domain.com/g' dummy/certbot-autoupdater.yaml
   ```
3. Apply the configuration 
   ```
   kubectl apply -f dummy/certbot-autoupdater.yaml -n <namespace>
   ```
4. The updater will run at 16:00 on 6th every month UTC time. To get the certificate now,
  1. Check the current utc time, and say for example its 14:01
  2. Update the cron for 14:03 using  
    ```
    kubectl patch cronjob certbot -A '{"spec":{"schedule": " 03 14 * *"}}'
    ```
  3. Wait for the cron to create pods 
    ```
    kubectl logs -n <namespace> -l app=certbot
    ```
  4. Once that's done, revert check the ssl using 
     ```
     https://new.domain.com
     ```
  5. After successful validation, change the cronjob to monthly
    ```
    kubectl apply -f dummy/certbot-autoupdater.yaml -n <namespace>
    ```
