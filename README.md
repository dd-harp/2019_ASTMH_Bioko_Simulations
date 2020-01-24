# Bioko Island Simulations, 2019

These are the scripts and simulations that I built in 2019 prior to ASTMH. The purpose of this set of documents was to accomplish a few things
  * Prepare materials for ASTMH poster presentation
  * Prepare for a malaria transmission and importations basic modeling and epidemiology paper, to be submitted to Malaria Journal
  * Prepare for a second paper related to propagating spatial uncertainty through a model, as a way of translating uncertainty in spatial estimates of PR into uncertainty in spatial estimates of transmission and other simulated outcomes

The contents of the included documents include:
  * Large data processing and cleaning, for translating the Bioko Island Malaria Elimination Program Malaria Indicator Survey data into usable model parameters
  * Workflow documents, for running simulations
  * Scripts for running simulations remotely on IHME's cluster

All data associated with this repository may be found at `/ihme/malaria_modeling/data/BIMEP_2019_Data`

Full contents:
  * scripts
    * Aggregate_travel_population_data.R - combine all data from the MIS: travel, census, etc
    * Care_Seeking_Model.R - modeling rate at which people seek care following symptoms
    * Map_Plots.R - example scripts for how to make (good) plots, for ASTMH poster and future publications
    * PR_surface_draw_assembly.R - assemble the surface draws from Carlos's geostatistical PR estimates
    * region_to_areaId_mapping.R - a script for mapping regional travel onto pixel-area travel, necessary for constructing the full TaR matrix
    * Travel_times.R - calculate travel times between each pair of locations, a necessary covariate for the destination selection model
    * Trip_duration_model.R - use exponential model to come up with trip durations, distinguishing between on-island and off-island trips
    * Trip_frequency_model.R - model the frequency with which people leave home
    * PR_surface_2017_traveler_pr.R - make a plot for PfPR among travelers (conditioning on travel, similar to Carlos's NComms paper)
    * Off_Island_Traveler.R - script for exploring the probability of traveling to each the subregions in mainland EG, but also extracting PR from each of these regions
  * report_sources
    * ASTMH_plots.Rmd - plots for ASTMH poster presentation
    * macro_pfsi_vignettes.Rmd - vignettes from `macro.pfsi` library, showing it's basic use
    * macro_pfsi_vignettes_2019-09-27.Rmd - updated vignettes
    * bioko_island_workflow.Rmd - workflow document, showing how to set up a bioko island simulation
    * bioko_island_workflow_vax.Rmd - similar workflow document, this time with vaccinations
    * TravelFraction_LocalResidual.Rmd - plotting Travel Fraction and Local Residual fraction
    * pfpr_uncertainties.Rmd - Explore pfpr data: are there obvious correlations between PfPR's uncertainty and things like sample size or underlying Aggregate_travel_population_data
