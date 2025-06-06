# End-to-End Cloud Data Pipeline for Retail Sales Forecasting
## Project Overview
This project is a comprehensive end-to-end data pipeline built. It ingests raw retail sales data from the M5 Forecasting dataset, transforms and models it using Spark and dbt, and automates the entire workflow using Kestra. The processed data is finally visualized through interactive dashboards on Looker Studio. The architecture is designed to be modular, scalable, and cost-efficient by leveraging cloud-native tools on Google Cloud Platform (GCP).
## Problem Statement
Retail data often exists in large, unstructured formats across multiple files, making it challenging to perform timely and reliable analysis. The objective of this project is to build a scalable pipeline that:<br>
* Centralizes disparate raw CSV files in cloud storage.<br>
* Cleans and transforms the data into a structured format for analysis.<br>
* Applies a dimensional modeling approach to support time-series forecasting and sales analysis.<br>
* Enables automation and observability through orchestration.<br>
* Presents insights through user-friendly dashboards.<br>
## Project Architecture
<img src="https://github.com/cc59chong/End-to-End-Cloud-Data-Pipeline-for-Retail-Sales-Forecasting/blob/main/project_architecture.PNG"><br>
## Data Flow
* Infrastructure Setup: Provisioned GCS buckets, BigQuery datasets, and IAM roles using Terraform.<br>
* Data Ingestion & Exploration: Uploaded raw CSVs to GCS and conducted initial exploration in Jupyter to understand schema, content, and data relationships.<br>
* Data Cleaning (Spark + Docker): Transformed raw data using PySpark scripts containerized via Docker. The output was stored in GCS in Parquet format to optimize -performance and storage.<br>
* Data Modeling (dbt + BigQuery): Created external tables in BigQuery and implemented a multi-layered dbt model (staging → marts → reports). Sampling strategy was used to develop on a manageable subset.<br>
* Orchestration (Kestra): Designed a Kestra workflow to trigger the dbt cloud job on a schedule or upon data arrival, handle job failures with email notifications, and ensure pipeline reliability.<br>
* Visualization (Looker Studio): Built interactive dashboards to analyze sales trends by time, product, and store, leveraging data from the final report tables in BigQuery.
## Tech Stack Used
* Cloud Platform: Google Cloud Platform (GCS, BigQuery, IAM)<br>
* Infrastructure-as-Code: Terraform<br>
* Data Transformation: Apache Spark (PySpark), Docker<br>
* Modeling & SQL Abstraction: dbt (with BigQuery)<br>
* Workflow Orchestration: Kestra<br>
* Visualization: Looker Studio<br>
* Development Environment: Jupyter, WSL on Windows<br>
## Pipeline Overview
### Table of Contents
```
~/de-project$ tree
.
├── 5m_exploratory_data_analysis.ipynb
├── Dockerfile
├── clean_data_spark.ipynb
├── conf
│   └── core-site.xml
├── docker-compose.yml
├── gcp
│   ├── credentials
│   │   └── gcp_credentials.json
│   └── gcs-connector-hadoop3-latest.jar
├── ivy_cache
├── kaggle-5m-data
│   ├── calendar.csv
│   ├── sales_train_validation.csv
│   └── sell_prices.csv
├── kestra-etl.yml
├── kestra-secrets.yml
├── m5-spark-cleaner
├── main.tf
├── spark_run_cleaning.py
└── terraform.tfstate
```
### 1. Infrastructure Setup (Using Terraform)
#### Objective
Establish the foundational infrastructure for the data project—object storage, data warehouse, and access controls—to prepare for subsequent data cleaning, modeling, and orchestration workflows.
**Key** : Raw/Cleaned data buckets in GCS；dataset in BigQuery; Secure access for Spark, dbt, and Kestra(IAM)
#### Setting Up GCP for Terraform Infrastructure Provisioning
To enable Terraform to deploy and manage infrastructure, the following GCP resources must be configured: 1. GCP Project Setup 2. Service Account & Authentication 3. Service Account & Authentication
#### Creating GCP infrastructure with Terraform
Configure all required infrastructure in a single `main.tf` file containing: 1. Provider configuration; 2. Resource definitions; 3. Variables and outputs.<br>
[Terraform_Bucket](/terraform/terraform-bucket.PNG)<br>
[Terraform_Dataset](/terraform/terraform-dataset.PNG)

### 2.Data Source Preparation & Exploratory Analysis
#### Objective
Ingest raw data into GCS, analyze its structure via Jupyter, design a star schema, and define data attributes including content, fields, date fields, and primary keys.
#### Upload M5 Raw CSV Files to Terraform-Provisioned GCS Bucket
 1. Download the [raw data](https://www.kaggle.com/competitions/m5-forecasting-accuracy/data)；2. Configure Cloud Tools；3. Upload CSV files to the designated raw data bucket `gsutil cp *.csv gs://m5-sales-raw-bucket/`<br>
[csv_Bucket](/exploratory_analysis/csv_bucket.PNG")<br><br>
**The dataset** <br>
`calendar.csv`: Contains the dates on which products are sold. The dates are in a yyyy/dd/mm format.<br>
`sales_train_validation.csv`: Contains the historical daily unit sales data per product and store [d_1 - d_1913].<br>
`sell_prices.csv`: Contains information about the price of the products sold per store and date.<br>
#### Exploratory Data Analysis in Jupyter Notebook 
`clean_data_spark.ipynb`
#### Star Schema Diagram and Table Documentation
<img src="https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/exploratory_analysis/star_schema.png" width="60%">
<img src="https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/exploratory_analysis/table_description.JPG">

### 3. Data Cleaning Logic (Spark + Docker)
#### Objective
Process M5 CSV data using Spark scripts, package the scripts into a Docker image for local development, and output the results to the GCS cleaned partition in Parquet format.
#### Develop Spark data transformation scripts
`clean_data_spark.ipynb`, `spark_run_cleaning.py`
#### Containerize with Docker for portability
`Dockerfile`<br>
[Image_Container](/spark%2Bdocker/image_container.PNG)
#### Output cleaned data as Parquet to GCS
<img src="https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/spark%2Bdocker/upload_data.PNG"><br>
**note** <br>
> `cleaned_data_parquet`: Contains all fully processed data in Parquet format (This will be used)
> * Test Folders
>> `cleaned_data_csv`：A CSV sample subset (generated in clean_data_spark.ipynb) is used to benchmark storage efficiency, confirming Parquet's superiority in performance and compression. <br>
>> `cleaned_data_parquet_docker`: Parquet-formatted sample data is used to verify the Docker pipeline's end-to-end functionality, including image builds and containerized execution.

### 4. Data Modeling (dbt + BigQuery)
#### Objective
Implement layered modeling (staging → marts → reports) using cleaned data
#### Create External Tables in BigQuery
Query Parquet files directly from GCS without BigQuery storage - cost-efficient with full query capabilities.<br>
```
-- create external table
CREATE OR REPLACE EXTERNAL TABLE `de-zoomcamp-project-456204.m5_sales_data.cleaned_parquet_external`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://m5-sales-cleaned-bucket/cleaned_data_parquet/*.parquet']
);
```
[Cleaned_Table](/dbt%2Bbigquery/cleaned_table.PNG)
#### dbt
To optimize development speed and control resource costs given the large dataset size (58+ million rows × 18 columns), I implemented a strategic sampling approach by extracting only the most recent year's data (2016) as a representative subset. This method maintained data characteristics while significantly reducing processing overhead during the development phase. <br>
<img src="https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/dbt%2Bbigquery/data_flow.PNG"><br>
**dbt Commands (Execution Sequence)** <br>
* Test Connection & Configuration：dbt debug<br>
* Run Full Pipeline: dbt build<br>
* Generate Documentation: dbt docs generate
[Success_Logs](/dbt%2Bbigquery/dbt_bulid.PNG)
#### Upload tables to BigQuery
[Upload_dbt_Data](/dbt%2Bbigquery/upload_dbt_data.PNG)
#### Git the dbt project to GitHub
[Git_dbt](/dbt%2Bbigquery/git.PNG)
![Final_tables](https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/dbt%2Bbigquery/final_table.PNG)
### 5. Workflow Orchestration with Kestra
#### Objective
This workflow automates the entire data pipeline with a single click: it continuously monitors BigQuery for new data, triggers dbt model builds via dbt Cloud, writes the results back to BigQuery upon successful execution, and sends email notifications in case of any failures.
#### Workflow Overview
<img src="https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/kestra/kestra_flow.PNG" width="70%"><br>
#### Setup Guide
1. Install Docker and Start Kestra Locally. [Docker_Kestra](/kestra/docker_kestra.PNG)
2. Use `docker-compose.yml` to launch Kestra, including the server and UI. <br>
3. Set up a GCP Service Account by navigating to the GCP Console, creating a new Service Account, and granting it the roles of BigQuery Data Viewer and BigQuery Job User. Finally, download the key file (.json) for authentication. (Skip the stage if you did this previously) <br>
4. Connect to dbt Cloud<br>
   * Get API Token：Login to dbt Cloud → Click avatar → Account Settings → API Tokens → Generate a Personal Token<br>
   * Get `account_id` and `job_id`:<br>
     * account_id: Visible in the URL: ```https://cloud.getdbt.com/#/accounts/**12345**/projects/...```<br>
     * job_id: Click your job → the ID is in the URL<br>
5.  Generate Gmail App Password: Go to Google Account Security → Enable 2-Step Verification → Open App Passwords → Choose app: Mail, name: kestra, then generate → 
 Copy the 16-digit password (used as EMAIL_PASSWORD)<br>
6. Set Variables in Kestra KV Store (note: Community Edition does not support UI-based secret creation. Use KV Store instead.) [Kestra+KVStore](/kestra/kestra_kvstore.PNG)
7. Write Kestra workflow `kestra-etl.yml`
### 6. Dashboard
With Looker Studio running, create insightful dashboards and reports using the report data stored in BigQuery.
<img src="https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/dashboard/sales_by_item.PNG">
<img src="https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/dashboard/sales_by_store.PNG">
<img src="https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/dashboard/sales_by_time.PNG">
## Conclusion
This project successfully delivers a cloud-based, production-grade data pipeline tailored for large-scale retail forecasting use cases. It demonstrates the integration of modern data engineering tools across the full lifecycle—from ingestion and transformation to orchestration and visualization. Key outcomes include:
* Efficient processing of 58M+ rows using Spark and Parquet.
* Modular dbt models following the best practices of the layered architecture.
* Fully automated workflow with failure handling and alerting.
* Insightful dashboards supporting business decision-making.<br>
This solution is scalable, maintainable, and easily extensible for future enhancements such as adding new metrics, integrating ML models, or supporting real-time data.
