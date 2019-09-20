## Deploying code changes via Github Webhooks in OpenShift

If you created an application from a template in the OpenShift Container Platform Service Catalog and deployed it to your OpenShift cluster, you might be wondering how you can can start iterating on your application. All you need to do to up Continuous Delivery with OpenShift is create a Github Webhook that will tell OpenShift to automatically pull in your newest changes to build and deploy.

If you would like a working starting point, a fully-functional application is available to be forked from the [IBM Node.js + Cloudant](https://github.com/IBM/nodejs-cloudant). You can use the 'Node.js + IBM Cloudant' tile on the Service catalog with your forked repository to create builds and deployments on OpenShift (This will provision a new Cloudant instance as well). After you get a Deployment set up, you can configure a webhook in your repository to make OpenShift automatically start a build whenever you push changes to your code. 

Note: Each time that you use the 'Node.js + IBM Cloudant' tile on the Service Catalog, a new instance of IBM Cloudant will be provisioned. Only one 'lite' instance of Cloudant is allowed per account. If you already have an instance of IBM Cloudant provisioned, and want to continue using the same instance, be sure to do optional Step #5 below to build and deploy _your_ repo, and do not use the 'Node.js + IBM Cloudant' tile to build and deploy your code.

From the Web Console homepage, navigate to your project
1. Click on Browse > Builds
2. Click the link with your BuildConfig name
3. Click the Configuration tab
4. Click on the Actions dropdown > Edit 
5. (Optional) Under Source Configuration enter your forked (or any other) Github Repository URL. This will tell OpenShift to build from your repo, instead of the IBM Sample repo. 
6. Click on Show Advanced Options 
7. Under Triggers, click create new Webhook Secret, give it a name, and click Generate and save the generated secret (you will need it later).
8. Click Save, and navigate back to the Configuration Tab
9. Click the "Copy to clipboard" icon to the right of the "GitHub webhook URL" field
10. Navigate to your repository on GitHub and click on repository settings > webhooks > Add webhook
11. Paste your webhook URL provided by OpenShift in the "Payload URL" field
12. Change the "Content type" to 'application/json'
13. Add the Secret value that you saved earlier.
14. Leave the defaults for the remaining fields — that's it!

Note: adding a webhook requires your OpenShift server to be reachable from GitHub.
