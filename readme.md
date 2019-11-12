<p align="center">
    <a href="http://kitura.io/">
        <img src="https://landscape.cncf.io/logos/ibm-cloud-kcsp.svg" height="100" alt="IBM Cloud">
    </a>
</p>


<p align="center">
    <a href="https://cloud.ibm.com">
    <img src="https://img.shields.io/badge/IBM%20Cloud-powered-blue.svg" alt="IBM Cloud">
    </a>
    <img src="https://img.shields.io/badge/platform-node-lightgrey.svg?style=flat" alt="platform">
    <img src="https://img.shields.io/badge/license-Apache2-blue.svg?style=flat" alt="Apache 2">
</p>


# Create and deploy a Node.js + Cloudant application

In this sample application, you will create a basic web application using Express to serve web pages in Node.js integrated complete with standard best practices, including a health check and application metric monitoring. In addition, this sample includes integration with Cloudant, a fully managed JSON document database.


## Steps

Install [IBM Cloud Developer Tools](https://cloud.ibm.com/docs/cli/index.html#overview) on your machine by using the following installation command: `curl -sL https://ibm.biz/idt-installer | bash`.

You can [deploy this application to IBM Cloud](https://cloud.ibm.com/developer/appservice/create-app?navMode=starterkits), deploy to OpenShift Container Platform, or [build it locally](#building-locally) by cloning this repo first.  Once your app is live, you can access the `/health` endpoint to build out your cloud native application.

### Deploy to IBM Cloud

Your application will be compiled with Docker containers. To compile and run your app, run:

```bash
ibmcloud dev build
ibmcloud dev run
```

This will launch your application locally.  When you are ready to deploy to IBM Cloud on CloudFoundry or Kubernetes, run one of the commands below:

```bash
ibmcloud dev deploy -t buildpack
ibmcloud dev deploy -t container
```

You can build and debug your app locally with:

```bash
ibmcloud dev build --debug
ibmcloud dev debug
```

### Deploy to OpenShift Container Platform

1. In a terminal, clone this repo and navigate to the application code's root directory.
2. If you do not have an existing IBM Cloud API key, use the `ibmcloud iam api-key-create` command to create one and note the API key string.
3. Use the `ibmcloud resource groups` command to find the ID of the resource group to associate with the application.
4. Use the `ibmcloud ks clusters` command to retrieve the name of the Kubernetes cluster where the application will be deployed.
5. Install required operators and this application's template by executing `./openshift/scripts/ibm-ocp-template-install.sh --apikey=<api_key> --resource-group-id=<resource_group_id> --cluster-name=<cluster_name>`.
6. In the IBM Cloud Console, navigate to your OpenShift cluster and open the OpenShift web console.
7. Navigate to the Service Catalog, locate the "Node.js + IBM Cloudant" tile and select it.
8. Follow the instructions to complete the deployment.

### Building Locally

To get started building this application locally, you can either run the application natively or use the [IBM Cloud Developer Tools](https://cloud.ibm.com/docs/cli?topic=cloud-cli-getting-started) for containerization and easy deployment to IBM Cloud.

#### Native Application Development

- Install the latest [Node.js](https://nodejs.org/en/download/) 6+ LTS version.

Once Node.js has been installed, you can download the project dependencies with:

```bash
npm install
```

To run your application locally:

```bash
npm run start
```

Your application will be running at `http://localhost:3000`.  You can access the `/health` endpoint at the host.

<!--#### IBM Cloud Developer Tools

-->

##### Session Store
You may see this warning when running `bx dev run`:
```
Warning: connect.session() MemoryStore is not
designed for a production environment, as it will leak
memory, and will not scale past a single process.
```
When deploying to production, it is best practice to configure sessions to be stored in an external persistence service.

## Next Steps
* Learn more about augmenting your Node.js applications on IBM Cloud with the [Node Programming Guide](https://cloud.ibm.com/docs/node).
* Explore other [sample applications](https://cloud.ibm.com/developer/appservice/starter-kits) on IBM Cloud.

## License

This sample application is licensed under the Apache License, Version 2. Separate third-party code objects invoked within this code pattern are licensed by their respective providers pursuant to their own separate licenses. Contributions are subject to the [Developer Certificate of Origin, Version 1.1](https://developercertificate.org/) and the [Apache License, Version 2](https://www.apache.org/licenses/LICENSE-2.0.txt).

[Apache License FAQ](https://www.apache.org/foundation/license-faq.html#WhatDoesItMEAN)
