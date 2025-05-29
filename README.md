🌐 Terraform-based Azure IoT + Synapse Project
📋 Project Summary
This project automates the provisioning of an end-to-end IoT data pipeline using Terraform on Microsoft Azure Cloud. It sets up an infrastructure that allows IoT devices to send telemetry data to an IoT Hub, route that data into a Storage Account with Data Lake Gen2, and ultimately integrates the data with Azure Synapse Analytics for advanced analytics and reporting.

🧱 Provisioned Resources
Resource Group

Central container for managing all deployed Azure resources.

Storage Account with Data Lake Gen2

Stores structured/unstructured IoT data with hierarchical namespace enabled.

Configured with a default filesystem and blob retention policy.

IoT Hub

Receives device-to-cloud messages.

Configured with fallback and custom routing to send messages to a storage endpoint.

IoT Hub Route & Endpoint

Custom Route sends messages from the IoT Hub to a Storage Container Endpoint.

Ensures JSON-formatted data is batch processed and stored with a naming convention.

Azure Synapse Workspace

Connects to the Data Lake for running analytics workloads.

Configured with admin credentials and system-assigned managed identity.

Public access disabled for security.

⚙️ Technologies Used
Terraform: Infrastructure as Code (IaC)

Azure RM Provider: For provisioning all Azure services

Git: Version control

Visual Studio Code: IDE for development

🐞 Issues Encountered & Resolved
Issue	Resolution
Terraform 404 error on storage account	Ensured dynamic storage name with random_string resource
Variable misuse in default value (random_suffix)	Removed interpolation from variable defaults – Terraform limitation
Duplicate provider configuration	Removed extra provider block from providers.tf
Provider inconsistency error on IoT endpoint	Used correct output values and added explicit depends_on where needed
Git push error (no remote configured)	Added remote repo using git remote add origin <URL>
CRLF warnings during Git add	Ignored – safe to proceed or configure .gitattributes to normalize line endings

✅ Outcomes
All Azure resources are now fully provisioned via Terraform.

IoT messages can be routed into secure storage and used for analytics.

Project is version-controlled and can be reused or extended.
