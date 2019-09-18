## Deploying code changes via Github Webhooks in OpenShift

If you created an application from a template in the OpenShift Container Platform Service Catalog and deployed it to your OpenShift cluster, you might be wondering how you can can start iterating on your application. All you need to do is set up Continuous Delivery with OpenShift is a Github Webhook that will tell OpenShift to automatically pull in your newest changes to build and deploy.

If you would like app as working starting-point the source code for this application is available to be forked from the [IBM Node.js + Cloudant](https://github.com/IBM/nodejs-cloudant). You can use the 'Node.js + IBM Cloudant' tile on the Service catalog with your forked repository to create builds and deployments on OpenShift. After you get a Deployment set up, you can configure a webhook in your repository to make OpenShift automatically start a build whenever you push your code:

From the Web Console homepage, navigate to your project
1. Click on Browse > Builds
2. Click the link with your BuildConfig name
3. Click the Configuration tab
4. Click on the Actions dropdown > Edit 
5. Click on Show Advanced Options 
6. Under Triggers, click create new Webhook Secret, give it a name, and click Generate and save the generated secret (you will need it later).
7. Click Save, and navigate back to the Configuration Tab
8. Click the "Copy to clipboard" icon to the right of the "GitHub webhook URL" field
9. Navigate to your repository on GitHub and click on repository settings > webhooks > Add webhook
10. Paste your webhook URL provided by OpenShift in the "Payload URL" field
11. Change the "Content type" to 'application/json'
12. Add the Secret value that you saved earlier.
13. Leave the defaults for the remaining fields — that's it!

Note: adding a webhook requires your OpenShift server to be reachable from GitHub.
