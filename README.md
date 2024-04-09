# Spark on AWS EMR Example
An example of running Spark on AWS EMR. Adapated from this [tutorial](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-gs.html).

## Running the example

To run the project locally:

1. Prepare data for S3 upload: `make data/food_establishment_data.csv`
1. Run Spark application: `python3 src/health_violations.py --data_source data/food_establishment_data.csv --output_uri data/output`

These steps are automated with `make run`. To see the results, run `cat data/output/part-*.csv`.

To run on AWS EMR:

1. Prepare data for S3 upload: `make data/food_establishment_data.csv`
1. Create a config file with a random bucket name: `bin/create-config`
1. Upload data and script to S3: `bin/upload-files`
1. Create cluster: `bin/create-cluster`
1. Submit application: `bin/submit-application`
1. Download output data: `bin/download-output`

All these steps can be automated with `make all`. Note, you may need to wait and run it again as it takes time for the processed results to be available. To see the results, run `cat data/output/analysis.csv`.

A few more things to consider:

1. Make sure to shutdown the EMR cluster with `bin/terminate-cluster`. You can also delete the bucket and its conent with `bin/delete-bucket`.
1. The scripts assume you have [jq](https://jqlang.github.io/jq/) installed. Most linux distribution probably have it already installed. If not, it should be easy to install it.

## License
This project is distributed under the MIT license. Please see `LICENSE` for more information.
