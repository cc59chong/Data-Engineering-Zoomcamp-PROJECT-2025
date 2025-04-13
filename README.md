# Data-Engineering-Zoomcamp-PROJECT-2025


### 1. Infrastructure Setup (Using Terraform)
#### Objective
Establish the foundational infrastructure for the data project—object storage, data warehouse, and access controls—to prepare for subsequent data cleaning, modeling, and orchestration workflows.
**Key** : Raw/Cleaned data buckets in GCS；dataset in BigQuery; Secure access for Spark, dbt, and Kestra(IAM)
#### Setting Up GCP for Terraform Infrastructure Provisioning
To enable Terraform to deploy and manage infrastructure, the following GCP resources must be configured: 1. GCP Project Setup 2. Service Account & Authentication 3. Service Account & Authentication
#### Creating GCP infrastructure with Terraform
Configure all required infrastructure in a single `main.tf` file containing: 1. Provider configuration; 2. Resource definitions; 3. Variables and outputs.
<imh src="https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/terraform/terraform-bucket.PNG">
<img src="https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/terraform/terraform-dataset.PNG">

### 2.Data Source Preparation & Exploratory Analysis
#### Objective
Ingest raw data into GCS, analyze its structure via Jupyter, design a star schema, and define data attributes including content, fields, date fields, and primary keys.
#### Upload M5 Raw CSV Files to Terraform-Provisioned GCS Bucket
 1. Download the [raw data](https://www.kaggle.com/competitions/m5-forecasting-accuracy/data)；2. Configure Cloud Tools；3. Upload CSV files to the designated raw data bucket `gsutil cp *.csv gs://m5-sales-raw-bucket/`
<img src="https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/exploratory_analysis/csv_bucket.PNG">
**The dataset**
- `calendar.csv` - Contains the dates on which products are sold. The dates are in a yyyy/dd/mm format.
- `sales_train_validation.csv` - Contains the historical daily unit sales data per product and store [d_1 - d_1913].
- `sell_prices.csv` - Contains information about the price of the products sold per store and date.
#### Exploratory Data Analysis in Jupyter Notebook 
`clean_data_spark.ipynb`
#### Star Schema Diagram and Table Documentation
<img src="https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/exploratory_analysis/star_schema.png" width="50%">
<img src="https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/exploratory_analysis/table_description.JPG">

### 3. Data Cleaning Logic (Spark + Docker)
#### Objective
Process M5 CSV data using Spark scripts, package the scripts into a Docker image for local development, and output the results to the GCS cleaned partition in Parquet format.
#### Develop Spark data transformation scripts
'clean_data_spark.ipynb`, `spark_run_cleaning'
#### Containerize with Docker for portability
`Dockerfile`
<img src="https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/spark%2Bdocker/image_container.PNG">
#### Output cleaned data as Parquet to GCS
<img src="https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/spark%2Bdocker/upload_data.PNG">
> note: Folder Structure for Testing:
>> `cleaned_data_parquet`: Contains all fully processed data in Parquet format (This will be used)




### 5. Workflow Orchestration with Kestra
#### Objective
This workflow automates the entire data pipeline with a single click: it continuously monitors BigQuery for new data, triggers dbt model builds via dbt Cloud, writes the results back to BigQuery upon successful execution, and sends email notifications in case of any failures.
#### Workflow Overview
![Kestra Workflow Diagram](https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/kestra/kestra_flow.PNG)
#### Setup Guide
1. Install Docker and Start Kestra Locally.
![Docker-Kestra](https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/kestra/docker_kestra.PNG)
2. Use `docker-compose.yml` to launch Kestra, including the server and UI.
3. Set up a GCP Service Account by navigating to the GCP Console, creating a new Service Account, and granting it the roles of BigQuery Data Viewer and BigQuery Job User. Finally, download the key file (.json) for authentication. (Skip the stage if you did this previously)
4. Connect to dbt Cloud
   * Get API Token：Login to dbt Cloud → Click avatar → Account Settings → API Tokens → Generate a Personal Token
   * Get `account_id` and `job_id`:
     * account_id: Visible in the URL: https://cloud.getdbt.com/#/accounts/**12345**/projects/...
     * job_id: Click your job → the ID is in the URL
5.  Generate Gmail App Password: Go to Google Account Security → Enable 2-Step Verification → Open App Passwords → Choose app: Mail, name: kestra, then generate → 
 Copy the 16-digit password (used as EMAIL_PASSWORD)
6. Set Variables in Kestra KV Store (note: Community Edition does not support UI-based secret creation. Use KV Store instead.)
![Kestra_KVstore](https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/kestra/kestra_kvstore.PNG)
7. Write Kestra workflow `kestra-etl.yml`
