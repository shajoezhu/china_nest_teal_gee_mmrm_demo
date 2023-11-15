## Load required packages
library(sparkline)
library(teal.modules.general)
library(teal.modules.clinical)
library(tern.gee)
library(tidyr)
library(dplyr)

# set adam_path here
dat <- fev_data
dat$AVALC <- fev_data$FEV1 > 30
dat$AVALBIN <- as.integer(dat$AVALC)
dat$AVAL <- fev_data$FEV1
dat$BASE<- fev_data$FEV1_BL
dat$PARAMCD <- "FEV"

## Load source datasets
ADSL <- unique(dat[c("USUBJID", "ARMCD", "RACE", "SEX")])
ADSL$STUDYID = "demo only"

ADRS = dat
ADRS = ADRS %>% filter(!is.na(AVALC))
ADRS$STUDYID = "demo only"




## Reusable configuration for modules
cs_arm_var <- choices_selected(
  choices = variable_choices(ADSL, subset = c("ARMCD")),
  selected = "ARMCD"
)

cs_demog_var <- choices_selected(
  choices = variable_choices(ADSL, c("SEX", "RACE")),
  selected = c("SEX", "RACE")
)

arm_ref_comp <- list(
  ARMCD = list(
    ref = "PBO",
    comp = c("TRT")
  )
)

## Setup App
app <- teal::init(
  data = cdisc_data(
    cdisc_dataset("ADSL", ADSL),
    cdisc_dataset("ADRS", ADRS)
  ),
  modules = modules(
    ## Data viewer modules from teal.modules.general
    tm_data_table("Data Table"),
    tm_variable_browser("Variable Browser"),
    ## Summary table module from teal.modules.clinical
    tm_t_summary(
      label = "Demographic Table",
      dataname = "ADSL",
      arm_var = cs_arm_var,
      summarize_vars = cs_demog_var
    ),
    tm_t_logistic(
      label = "Logistic Regression",
      dataname = "ADRS",
      arm_var = cs_arm_var,
      arm_ref_comp = arm_ref_comp,
      paramcd = choices_selected(
        choices = value_choices(ADRS, "PARAMCD"),
        selected = NULL,
      ),
      cov_var = choices_selected(
        choices = c("SEX", "RACE"),
        selected = c("SEX", "RACE")
      )
    ),
    tm_a_gee(
      label = "GEE",
      dataname = "ADRS",
      aval_var = choices_selected("AVALBIN", fixed = TRUE),
      id_var = choices_selected(c("USUBJID", "SUBJID"), "USUBJID"),
      arm_var = choices_selected(c("ARMCD"), "ARMCD"),
      visit_var = choices_selected(c("AVISIT"), "AVISIT"),
      paramcd = choices_selected(
        choices = value_choices(ADRS, "PARAMCD"),
        selected = NULL
      ),
      cov_var = choices_selected(
        choices = c("SEX", "RACE"),
        selected = c("SEX", "RACE")
      )
    ),
    tm_a_mmrm(
      label = "MMRM",
      dataname = "ADRS",
      aval_var = choices_selected("AVAL", fixed = TRUE),
      id_var = choices_selected(c("USUBJID", "SUBJID"), "USUBJID"),
      arm_var = choices_selected(c("ARMCD"), "ARMCD"),
      visit_var = choices_selected(c("AVISIT"), "AVISIT"),
      arm_ref_comp = arm_ref_comp,
      paramcd = choices_selected(
        choices = value_choices(ADRS, "PARAMCD"),
        selected = NULL
      ),
      cov_var = choices_selected(
        choices = c("SEX", "RACE"),
        selected = c("SEX", "RACE")
      )
    )
    
    
  ),
  
  header = div(
    tags$h1("Teal app for study XX12345")
  )
)

runApp(app)
