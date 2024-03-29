import argparse

from pyspark.sql import SparkSession
from pyspark.sql import functions as F


def calculate_red_violations(data_source, output_uri):
    """
    Processes sample food establishment inspection data and queries the data to find the top 10 establishments
    with the most Red violations from 2006 to 2020.

    :param data_source: The URI of your food establishment data CSV, such as 's3://DOC-EXAMPLE-BUCKET/food-establishment-data.csv'.
    :param output_uri: The URI where output is written, such as 's3://DOC-EXAMPLE-BUCKET/restaurant_violation_results'.
    """
    with SparkSession.builder.appName("Calculate Red Health Violations").getOrCreate() as spark:
        # Load the restaurant violation CSV data
        if data_source is not None:
            df_restaurants = spark.read.option("header", "true").csv(data_source)

        # Create a DataFrame of the top 10 restaurants with the most Red violations
        top_red_violation_restaurants = (
            df_restaurants
            .filter(F.col("violation_type") == "RED")
            .groupBy("name")
            .count()
            .withColumnRenamed("count", "total_red_violations")
            .sort("total_red_violations", ascending=False)
            .limit(10)
        )

        # Write the results to the specified output URI
        (
            top_red_violation_restaurants
            .write
            .option("header", "true")
            .mode("overwrite")
            .csv(output_uri)
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--data_source', help="The URI for you CSV restaurant data, like an S3 bucket location.")
    parser.add_argument(
        '--output_uri', help="The URI where output is saved, like an S3 bucket location.")
    args = parser.parse_args()

    calculate_red_violations(args.data_source, args.output_uri)
			
