# Wikipedia Search Engine with PySpark and Terraform on AWS EMR

This project demonstrates the implementation of a classic information retrieval system using **Term Frequency-Inverse Document Frequency (TF-IDF)** on a Wikipedia dataset. The entire infrastructure is provisioned on **Amazon Web Services (AWS)** using **Terraform**, and the data processing is performed with **Apache Spark** on **EMR Serverless**.

The goal is to showcase a scalable, automated, and cloud-native approach to big data analysis, combining Infrastructure as Code (IaC), distributed computing, and fundamental machine learning concepts.

## 🌟 Key Skills Showcased
- **Cloud Infrastructure Automation (IaC):** Using **Terraform** to define, provision, and manage all AWS resources in a repeatable and version-controlled manner.
- **Big Data Processing:** Leveraging **Apache Spark** via **PySpark** on **EMR Serverless** for efficient, distributed processing of text data without managing server clusters.
- **Cloud Architecture:** Designing a robust AWS ecosystem involving **EMR Studio** (for interactive development), **EMR Serverless** (for job execution), **S3** (for data storage), **IAM** (for secure access), and networking (**VPC**, Subnets).
- **Data Engineering & ETL:** Performing a complete Extract, Transform, Load (ETL) pipeline—ingesting raw text data, cleaning it, transforming it into numerical features (TF-IDF vectors), and loading the results for analysis.
- **Machine Learning Concepts:** Implementing the **TF-IDF algorithm** using Spark's MLlib to rank documents by relevance for a given search query.
- **DevOps Best Practices:** Structuring code for reusability, automating infrastructure setup and teardown, and creating a clear execution path for the data processing job.

## 📖 Project Overview

This project builds a simple search engine. Given a query (e.g., "Gettysburg"), it analyzes a dataset of Wikipedia articles and returns the most relevant ones based on their TF-IDF scores.

### How it Works: The TF-IDF Algorithm
TF-IDF is a numerical statistic that reflects how important a word is to a document in a collection or corpus. It is the product of two metrics:

1.  **Term Frequency (TF):** How often a word appears in a document. A word that appears many times has a higher TF.
    - $TF(t, d) = \frac{\text{(Number of times term t appears in a document)}}{\text{(Total number of terms in the document)}}$
2.  **Inverse Document Frequency (IDF):** A measure of how much information the word provides. It scales down common words (like "the" or "a") that appear in many documents and scales up rare words that are more informative.
    - $IDF(t, D) = \log\left(\frac{\text{Total number of documents}}{\text{Number of documents with term t in it}}\right)$

The final **TF-IDF score** is simply $TF \times IDF$. Articles with the highest TF-IDF score for the search term are considered the most relevant.

***

## 🏛️ Architecture on AWS

This project is deployed entirely on AWS, with infrastructure managed by Terraform.



1.  **S3 (Simple Storage Service):** Acts as our data lake, storing the raw Wikipedia dataset (`subset-small.tsv`), the PySpark processing script, and the development notebook.
2.  **IAM (Identity and Access Management):** Provides granular security with specific roles for EMR Studio and EMR Serverless to ensure they only have the permissions they need.
3.  **VPC (Virtual Private Cloud):** Creates an isolated network environment with subnets and security groups, which is a prerequisite for running EMR Studio.
4.  **EMR Serverless:** A serverless option for running Spark applications. We submit our PySpark script to it, and AWS handles the provisioning and scaling of compute resources automatically.
5.  **EMR Studio:** An IDE for interactive development. The Terraform setup provisions a studio where the original Jupyter Notebook can be run for exploration.
6.  **CloudWatch & SNS:** A billing alarm is configured to monitor estimated AWS charges and send an email notification via **SNS (Simple Notification Service)** if costs exceed a defined threshold.

***

## 🚀 How to Run This Project

Follow these steps to deploy the infrastructure and run the data processing job.

### Prerequisites
1.  **AWS Account:** With an IAM user configured (do not use the root account).
2.  **Terraform:** Installed on your local machine.
3.  **AWS CLI:** Installed and configured (`aws configure`).
4.  **Project Files:** Clone this repository to your local machine.

### Step 1: Provision the Infrastructure
The Terraform configuration will create the S3 bucket, upload the necessary files, set up all IAM roles and networking, and deploy the EMR Serverless application.

1.  Navigate to the project's root directory.
2.  Initialize Terraform:
    ```bash
    terraform init
    ```
3.  Apply the configuration. You will be prompted to enter an email address for billing alerts.
    ```bash
    terraform apply -var="notification_email=your-email@example.com"
    ```
    Review the plan and type `yes` to proceed.

> **🚨 IMPORTANT:** After applying, check your email and **confirm the AWS SNS subscription** to activate the billing alarm.

### Step 2: Execute the PySpark Job
Once the infrastructure is ready, submit the Spark job to EMR Serverless.

1.  Set the environment variables using the outputs from Terraform:
    ```bash
    export APP_ID=$(terraform output -raw emr_serverless_app_id)
    export ROLE_ARN=$(terraform output -raw emr_serverless_execution_role_arn)
    export SCRIPT_URI=$(terraform output -raw s3_script_uri)
    export DATA_URI=$(terraform output -raw s3_data_uri)
    ```

2.  Run the `start-job-run` command:
    ```bash
    aws emr-serverless start-job-run \
      --application-id $APP_ID \
      --execution-role-arn $ROLE_ARN \
      --job-driver '{
          "sparkSubmit": {
              "entryPoint": "'$SCRIPT_URI'",
              "entryPointArguments": ["'$DATA_URI'"],
              "sparkSubmitParameters": "--conf spark.executor.cores=2 --conf spark.executor.memory=4g --conf spark.driver.cores=1 --conf spark.driver.memory=2g --conf spark.executor.instances=2"
          }
      }'
    ```

The job will start, and you can monitor its progress in the AWS EMR console. Upon completion, the output logs will show the top Wikipedia articles related to "Gettysburg."

### Step 3: Clean Up
To avoid ongoing AWS charges, destroy all the resources created by Terraform with a single command.

```bash
terraform destroy -var="notification_email=your-email@example.com"
```
Type `yes` to confirm the deletion of all resources.

***

## 📓 Role of the Jupyter Notebook

This repository contains both a Jupyter Notebook (`tfidf.ipynb`) and a standalone Python script (`tfidf_job.py`). This separation reflects a standard industry workflow:

-   **`tfidf.ipynb` (Development):** The notebook is an interactive environment perfect for developing, exploring data, and prototyping the TF-IDF logic cell by cell.
-   **`tfidf_job.py` (Production):** This script contains the finalized, clean code from the notebook, refactored to run as an automated, non-interactive job. This is the script we submit to EMR Serverless.

The Terraform configuration automatically provisions an EMR Studio and uploads the notebook to S3, making it available for further interactive exploration if needed.
