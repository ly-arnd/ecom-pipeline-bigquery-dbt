import os
from airflow.sdk import DAG
from cosmos import DbtDag
from cosmos.config import ProjectConfig, ExecutionConfig, ProfileConfig
from cosmos.profiles import GoogleCloudServiceAccountFileProfileMapping
from datetime import datetime, timedelta
from typing import Final

DBT_PROJECT_PATH : Final[str] = "/opt/dbt/ecommerce_datahub"
DBT_PROFILE_NAME : Final[str] = "ecommerce_datahub"
DBT_TARGET_ENV : Final[str] = "dev"

profile_config = ProfileConfig(
    profile_name=DBT_PROFILE_NAME,
    target_name=DBT_TARGET_ENV,
    profile_mapping=GoogleCloudServiceAccountFileProfileMapping(
        conn_id="google_cloud_default",
        profile_args={
            "project": os.environ["GCP_PROJECT_ID"],
            "dataset": "landing",
            "location": os.environ.get("GCP_BQ_LOCATION", "EU"),
        },
    ),
)

execution_config = ExecutionConfig(
    dbt_executable_path=os.environ["DBT_BIN_PATH"],
)

project_config = ProjectConfig(
    dbt_project_path=DBT_PROJECT_PATH
)

dbt_run = DbtDag(
    dag_id=f"dbt_{DBT_PROFILE_NAME}_{DBT_TARGET_ENV}",
    start_date=datetime(2024, 1, 1),
    schedule="@daily",
    catchup=False,
    max_active_runs=1,

    project_config=project_config,
    profile_config=profile_config,
    execution_config=execution_config,

    operator_args={
        "append_env": True,
        "dbt_cmd_flags": ["--no-partial-parse"],
    },

    tags=["dbt", "bigquery", DBT_PROFILE_NAME, DBT_TARGET_ENV],
)
