---
layout: post
comments: true
publish: true
title: Service Principal access to dedicated capacity XMLA endpoint
date: 2020-06-02
author: Daniel Otykier
authorurl: http://twitter.com/dotykier
---

This article provides a step-by-step instruction on how to enable Service Principal (SP) access to a Power BI workspace in dedicated capacity (Power BI Premium or embedded/A sku).

In the following, I will try to highlight the minimal number of steps necessary to enable Service Principal authentication. You can find all the details in the official documentation: [Automate Premium workspace and dataset tasks using service principals](https://docs.microsoft.com/en-us/power-bi/admin/service-premium-service-principal).

## Why Service Principal access?
In order to set up unattended jobs or pipelines that perform XMLA write operations (refresh, deploy, etc.) on a dataset in a Power BI workspace, we have to use a Service Principal. Specifically, if we want to use Tabular Editor's command-line interface to perform a model deployment, we don't have any other options, as the command-line does not allow interactive authentication, which is required on any tenant that has multi-factor authentication (MFA) enabled.

These are the steps we need to go through in order to set this up. Note, these steps has to be performed by a user with Power BI Administrator and Azure Active Directory Administrator permissions:

- [Enable XMLA read/write access on a Power BI workspace](#enable-xmla-readwrite-access-on-a-power-bi-workspace)
- [Create a Service Principal](#create-a-service-principal)
- [Create a Security Group and include the SP](#create-a-security-group-and-include-the-sp)
- [Enable Service Principal API access](#enable-service-principal-api-access)
- [Set Service Principal as Workspace Admin](#set-service-principal-as-workspace-admin)
- [Connect with Tabular Editor](#connect-with-tabular-editor)

### Enable XMLA read/write access on a Power BI workspace
For most scenarios that involve Tabular Editor, we need to [enable XMLA read/write](https://aka.ms/XmlaEndPoint) on our Power BI workspace.

1. In the Power BI Admin Portal, go to Capacity Settings. If your organization uses Power BI Premium, locate the capacity that hosts your workspace under the "Power BI Premium" tab. If your capacity is a Power BI Embedded or A SKU, locate it under the "Power BI Embedded" tab. Click on the capacity name.

<img width="1200" alt="Locating the capacity settings" src="https://user-images.githubusercontent.com/8976200/83491557-43644480-a4b2-11ea-85c1-e37c3fa4d12c.png">

{:start="2"}
2. Expand the "Workloads" section. Scroll down and locate the XMLA Endpoint dropdown. Set it to "Read Write". Note: At the time of this writing, there's a bug that requires you to also disable the "Dataflows" workload. Click "Apply".
 
<img width="328" alt="Enabling XMLA read/write on dedicated capacity" src="https://user-images.githubusercontent.com/8976200/83491762-8cb49400-a4b2-11ea-9668-2786e94a4f80.png">

{:start="3"}
3. At this point, you should be able to connect using interactive (personal) authentication and make changes to datasets in the workspace using Tabular Editor, provided your user is an administrator of the workspace. Use the following string as the "server name" when connecting:

```
powerbi://api.powerbi.com/v1.0/<organization name>/<workspace name>
```

<img width="400" alt="Connecting to a Power BI dataset using Tabular Editor" src="https://user-images.githubusercontent.com/8976200/83492010-ed43d100-a4b2-11ea-98cc-be63b0a68ddd.png">

*Warning: Once you make a change to a dataset hosted in an XMLA write-enabled workspace using external tools such as Tabular Editor, you will no longer be able to download a .pbix file from the dataset. This is a limitation on the Power BI Service which will hopefully not apply once XMLA read/write reaches general availability (it's still in preview as of this writing).*

### Create a Service Principal

1. In the Azure Portal, go to Azure Active Directory. Take a note of the Tenant ID. You will need it later, when specifying the connection string.
2. Go to "App Registrations", click "New registration".

<img width="600" alt="Screenshot 2020-06-02 at 09 31 40" src="https://user-images.githubusercontent.com/8976200/83492653-e36e9d80-a4b3-11ea-973c-707bcbf21e23.png">

{:start="3"}
3. Provide a name for the Service Principal. Leave the account type setting as single tenant and the redirect URI blank. Hit "Register".
4. Take a note of the Application (client) ID. This will also be needed later, when specifying the connection string.

<img width="1200" alt="Screenshot 2020-06-02 at 09 35 22" src="https://user-images.githubusercontent.com/8976200/83493152-a3f48100-a4b4-11ea-938e-500ee691949f.png">

{:start="5"}
5. Click on "Certificates & Secrets" and then "New client secret". Description is optional. Set the expiration as desired (but remember that you'll have to update any connection strings that use the Service Principal later on, when the secret expires).
6. Write down the secret. You won't be able to retrieve it later on, and it is needed when specifying the connection string.

### Create a Security Group and include the SP

1. Go back to Azure Active Directory in the Azure Portal. Click on "Groups". Then "New Group".
2. Leave the "Group type" as "Security", give it a name and an optional description.
3. Go to "Members" of the newly created group. Click "Add members" and then search for the Service Principal you created above, using its **name** as the filter string.

<img width="1100" alt="Screenshot 2020-06-02 at 09 44 37" src="https://user-images.githubusercontent.com/8976200/83493855-b327fe80-a4b5-11ea-8415-2f0e36c1c472.png">

### Enable Service Principal API access

1. Log in to PowerBI.com as a user with admin access (that is, the user has the "Power BI Administrator" permission assigned in Azure Active Directory).
2. Go to the Admin Portal, click "Tenant Settings".
3. Scroll down to locate the "Developer section". Expand "Allow service principals to use Power BI APIs".
4. Enable the setting. Under "Apply to", make sure "Specific security groups (Recommended)" has been selected, and enter the name of the security group you created in the previous step. Click "Apply".

<img width="600" alt="Screenshot 2020-06-02 at 09 47 01" src="https://user-images.githubusercontent.com/8976200/83494107-0f8b1e00-a4b6-11ea-9a0a-3fb759cecfaa.png">

### Set Service Principal as Workspace Admin

1. Go to the Power BI Workspace. Click "Access".
2. Type the name of the Service Principal into the email address field. Set the dropdown below to "Admin". Click "Add"

<img width="1200" alt="Screenshot 2020-06-02 at 09 52 06" src="https://user-images.githubusercontent.com/8976200/83494553-bec7f500-a4b6-11ea-8ff9-18b4ba242465.png">
 
### Connect with Tabular Editor

*Note: You need the [latest version (2.10.0) of Tabular Editor](https://github.com/otykier/TabularEditor/releases/latest), for this last step to work, as the Power BI Service manages the database IDs independently of their names, and previous versions of Tabular Editor always assumed identical databases IDs and names. If you're using an earlier version, you may not be able to overwrite an existing dataset, and you might see an error message even after successful deployment.*

Sometimes, it can take a few minutes for all of these settings to come through. Grab a cup of coffee. When you come back, you can test the Service Principal connection using Tabular Editor. Provide the following connection string as the "server name" when connecting:

```
Provider=MSOLAP;Data Source=<xmla endpoint>;User ID=app:<application id>@<tenant id>;Password=<application secret>
```

Make sure to replace the placeholders with their actual values:

- &lt;xmla endpoint&gt; (same as when connecting manually: `powerbi://api.powerbi.com/v1.0/<organization name>/<workspace name>`)
- &lt;application id&gt; (from Service Principal)
- &lt;tenant id&gt; (from Azure Active Directory)
- &lt;application secret&gt; (from Service Principal)

<img width="400" alt="Screenshot 2020-06-02 at 09 52 06" src="https://user-images.githubusercontent.com/8976200/83494985-60e7dd00-a4b7-11ea-9187-d56523237b09.png">

The same connection string can be used when invoking Tabular Editor through the command-line interface. For example, to deploy a local Model.bim file as a dataset named "AdventureWorks" use the following command. The `-O` switch allows you to overwrite an existing dataset with the same name:

```
start /wait TabularEditor.exe Model.bim -D "Provider=MSOLAP;Data Source=<xmla endpoint>;User ID=app:<application id>@<tenant id>;Password=<application secret>" "AdventureWorks" -O
```

[More information on the command line syntax here](https://github.com/otykier/TabularEditor/wiki/Command-line-Options).

That's it! Feel free to post questions below or on [GitHub](https://github.com/otykier/tabulareditor/issues). 
