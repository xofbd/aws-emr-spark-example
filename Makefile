SHELL := /bin/bash
DATA_DIR := data
OUTPUT_DIR := $(DATA_DIR)/output

.PHONY: all
all: clean $(OUTPUT_DIR)/analysis.csv

# Data prep
$(DATA_DIR) $(OUTPUT_DIR):
	mkdir -p $@

.INTERMEDIATE: $(DATA_DIR)/food_establishment_data.zip
$(DATA_DIR)/food_establishment_data.zip: | $(DATA_DIR)
	wget -P $(DATA_DIR) https://docs.aws.amazon.com/emr/latest/ManagementGuide/samples/food_establishment_data.zip

$(DATA_DIR)/food_establishment_data.csv: $(DATA_DIR)/food_establishment_data.zip 
	unzip -d $(DATA_DIR) $<

# Running locally
.PHONY: run
run: $(DATA_DIR)/food_establishment_data.csv
	python3 src/health_violations.py --data_source $< --output_uri $(OUTPUT_DIR)

# Running in AWS
config: $(DATA_DIR)/food_establishment_data.csv
	bin/create-config

.make.upload-files: config
	bin/upload-files
	touch $@

.make.cluster: config
	bin/create-cluster
	touch $@

.make.submit-app: .make.upload-files .make.cluster
	bin/submit-application
	touch $@

$(OUTPUT_DIR)/analysis.csv: .make.submit-app $(wildcard $(OUTPUT_DIR)/part-*.csv)
	bin/download-output
	cat $(OUTPUT_DIR)/part-*.csv > $@
	rm $(OUTPUT_DIR)/part-*.csv

# Utilities
.PHONY: clean
clean: clean-local clean-remote

.PHONY: clean-local
clean-local:
	rm -rf $(DATA_DIR) .make.*

.PHONY: clean-remote
clean-remote:
	bin/delete-bucket || true
	bin/termindate-cluster || true
