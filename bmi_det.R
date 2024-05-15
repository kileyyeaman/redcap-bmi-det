library(plumber)
library(cdcanthro)
library(REDCapR)

redcap_uri <- "https://redcap-api.chop.edu/api/"
# token <- TOKEN REDACTED

#* @apiTitle BMI Calculator for REDCap
#* @apiDescription An API that utilizes the CDC's BMI calculator package to return BMI z-scores and percentiles to REDCap

#* Calculate Z-scores/percentiles and write to REDCap
#* @param record The record ID in the project
#* @post /bmi_calculator
function(record) {
  fields <- c("sex", "age", "wt", "ht", "bmi")
  record <-as.character(record)
  
  # Read data from REDCap
  redcap_data <- redcap_read_oneshot(redcap_uri,
                                     token,
                                     records = c(record),
                                     records_collapsed = record,
                                     fields)$data
  
  # Use CDC calculator to calculate Z-scores and percentiles
  cdc_bmi_data <- cdcanthro(redcap_data,
                            redcap_data$age,
                            redcap_data$wt,
                            redcap_data$ht,
                            redcap_data$bmi)
  # Add record to data frame
  cdc_bmi_data$record_id <- as.numeric(record)
  
  # Write dataframe back to REDCap
  redcap_write_oneshot(cdc_bmi_data,
                       redcap_uri,
                       token)
}
