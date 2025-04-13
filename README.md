# Data-Engineering-Zoomcamp-PROJECT-2025




### Phase 5: Workflow Orchestration with Kestra
#### Goal
This workflow automates the entire data pipeline with a single click: it continuously monitors BigQuery for new data, triggers dbt model builds via dbt Cloud, writes the results back to BigQuery upon successful execution, and sends email notifications in case of any failures.
#### Workflow Overview
![Kestra Workflow Diagram](https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/kestra/kestra_flow.PNG)
*Figure: Kestra Workflow Diagram*
#### Setup Guide
1. Install Docker and Start Kestra Locally.
![Docker-Kestra](https://github.com/cc59chong/Data-Engineering-Zoomcamp-PROJECT-2025/blob/main/kestra/docker_kestra.PNG)
2. Use `docker-compose.yml` to launch Kestra, including the server and UI.
3. Set up a GCP Service Account by navigating to the GCP Console, creating a new Service Account, and granting it the roles of BigQuery Data Viewer and BigQuery Job User. Finally, download the key file (sa.json) for authentication.
4. Connect to dbt Cloud
   * Get API Token：Login to dbt Cloud → Click avatar → Account Settings → API Tokens → Generate a Personal Token
   * Get 'account_id' and 'job_id':
   * * account_id: Visible in the URL: https://cloud.getdbt.com/#/accounts/**12345**/projects/...
     * job_id: Click your job → the ID is in the URL
5.  
