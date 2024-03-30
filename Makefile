SHELL := /bin/bash
DATA_DIR := data

.PHONY: all
all: clean $(DATA_DIR)/food_establishment_data.csv

$(DATA_DIR):
	mkdir -p $@

.INTERMEDIATE: $(DATA_DIR)/food_establishment_data.zip
$(DATA_DIR)/food_establishment_data.zip: | $(DATA_DIR)
	wget -P $(DATA_DIR) https://docs.aws.amazon.com/emr/latest/ManagementGuide/samples/food_establishment_data.zip

$(DATA_DIR)/food_establishment_data.csv: $(DATA_DIR)/food_establishment_data.zip 
	unzip -d $(DATA_DIR) $<

.PHONY: run
run: $(DATA_DIR)/food_establishment_data.csv
	python3 src/health_violations.py --data_source $< --output_uri $(DATA_DIR)

.PHONY: clean
clean:
	rm -rf $(DATA_DIR)
