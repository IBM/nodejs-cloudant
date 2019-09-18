## Deploying code changes via Github Webhooks

The source code for this application is available to be forked from the [IBM Node.js Cloudant](https://github.com/IBM/nodejs-cloudant) repository. You may need to create a new deployment via the 'Node.js + IBM Cloudant' tile on the Service catalog with your forked repository if you haven't done so already. You can configure a webhook in your repository to make OpenShift automatically start a build whenever you push your code:

From the Web Console homepage, navigate to your project
1. Click on Browse > Builds
2. Click the link with your BuildConfig name
3. Click the Configuration tab
4. Click on the Actions dropdown, and click 'Edit'
5. Click on 'Show Advanced Options' 
6. Under Triggers, click create new Webhook Secret, give it a name, and click Generate and save the generated secret (you will need it later).
7. Save the build configuration, and navigate back to the Configuration Tab
8. Click the "Copy to clipboard" icon to the right of the "GitHub webhook URL" field
9. Navigate to your repository on GitHub and click on repository settings > webhooks > Add webhook
10. Paste your webhook URL provided by OpenShift in the "Payload URL" field
11. Change the "Content type" to 'application/json'
12. Add the Secret value that you saved earlier.
13. Leave the defaults for the remaining fields — that's it!

Note: adding a webhook requires your OpenShift server to be reachable from GitHub.
