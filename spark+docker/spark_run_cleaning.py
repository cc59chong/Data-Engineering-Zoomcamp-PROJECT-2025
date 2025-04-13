from pyspark.sql import SparkSession
from pyspark.sql.functions import col, regexp_extract, expr
from pyspark.sql.types import IntegerType

def create_spark_session():
    """
    Creates a SparkSession with the necessary configurations.
    
    Returns:
        SparkSession: The created SparkSession.
    """
    return SparkSession.builder \
        .appName("m5-cleaning") \
        .config("spark.jars", "/app/gcs-connector-hadoop3-latest.jar") \
        .config("spark.driver.extraJavaOptions", "-Divy.home=/app/.ivy2") \
        .config("spark.executor.extraJavaOptions", "-Divy.home=/app/.ivy2") \
        .config("spark.hadoop.google.cloud.auth.service.account.enable", "true") \
        .config("spark.hadoop.google.cloud.auth.service.account.json.keyfile", "/app/credentials/gcp_credentials.json") \
        .config("spark.hadoop.security.authentication", "simple") \
        .getOrCreate()

def clean_calendar(calendar):
    calendar = calendar.withColumn("date", col("date").cast("date"))
    calendar = calendar.fillna({
        "event_name_1": "No_event",
        "event_name_2": "No_event",
        "event_type_1": "No_event",
        "event_type_2": "No_event",
    })
    calendar = calendar.withColumn("d", regexp_extract(col("d"), r"d_(\d+)", 1).cast(IntegerType()))
    calendar = calendar.filter(col("d") <= 1913)
    columns_to_drop = ["weekday", "wday", "month", "year"]
    for col_name in columns_to_drop:
        if col_name in calendar.columns:
            calendar = calendar.drop(col_name)
    return calendar

def clean_sales(sales):
    date_cols = [c for c in sales.columns if c.startswith("d_")]
    id_vars = ['item_id', 'dept_id', 'cat_id', 'store_id', 'state_id']
    stack_expr = "stack({}, {})".format(
        len(date_cols),
        ", ".join([f"'{c}', `{c}`" for c in date_cols])
    )
    sales_long = sales.select(
        *id_vars,
        expr(stack_expr).alias("day", "sales")
    )
    sales_long = sales_long.withColumn("day", regexp_extract(col("day"), r"d_(\d+)", 1).cast(IntegerType()))
    return sales_long

def main():
    spark = create_spark_session()

    calendar = spark.read.csv("gs://m5-sales-raw-bucket/calendar.csv", header=True)
    sales = spark.read.csv("gs://m5-sales-raw-bucket/sales_train_validation.csv", header=True)
    sell_prices = spark.read.csv("gs://m5-sales-raw-bucket/sell_prices.csv", header=True)

    # calendar = spark.read.csv("/app/kaggle-5m-data/calendar.csv", header=True)
    # sales = spark.read.csv("/app/kaggle-5m-data/sales_train_validation.csv", header=True)
    # sell_prices = spark.read.csv("/app/kaggle-5m-data/sell_prices.csv", header=True)

    calendar = clean_calendar(calendar)
    sales_long = clean_sales(sales)

    final_data = sales_long \
        .join(calendar, sales_long.day == calendar.d, how="left") \
        .drop(calendar.d)

    final_data = final_data \
        .join(sell_prices, on=["store_id", "item_id", "wm_yr_wk"], how="left")

    final_data.write.mode("overwrite") \
        .format("parquet") \
        .option("compression", "snappy") \
        .save("gs://m5-sales-cleaned-bucket/cleaned_data_parquet_spark")

    spark.stop()

if __name__ == "__main__":
    main()
