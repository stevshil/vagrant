# Testing node/pod connectivity

To ensure your cluster is routing correctly you can test it by doing the following;

1. Deploy the test environment
   ```
   cd /vagrant/files/testscripts
   kubectl apply -f 01-overlaytest.yml
   ```
2. Wait for deployment to succeed
   ```
   ./02-checkbuild
   ```
   This will wait for the environment to be available
3. Execute the test
   ```
   ./03-overlaytest
   ```
   If you see cannot connect or no route then you have a networking issue, and could be down to having multiple NICs.
