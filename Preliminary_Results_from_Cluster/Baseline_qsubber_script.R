##
#
# Qsubber prototype for Baseline
# Daniel T Citron
# 10/7/19
#
##
# Submit a set of jobs, where each job corresponds to a single run of the simulation
# 10/7/19 - We will, at first, submit 100 jobs, and then tomorrow make sure we can analyze them

# This is the qsub call

for (i in 1:100){
  sys.sub <- paste0("qsub -l m_mem_free=1G -l fthread=1 -P proj_mmc -q all.q",
                    " -N baseline_",i,
                    " -o /ihme/malaria_modeling/dtcitron/SpatialUncertainty/Baseline/log_files", # where output will go
                    " -e /ihme/malaria_modeling/dtcitron/SpatialUncertainty/Baseline/log_files"  # where errors will go
  )
  
  
  # This is a shell script, says which R to use, and passes arguments to the R script
  shell <- "/ihme/singularity-images/rstudio/shells/execRscript.sh" 
  # R script to execute
  script <- paste("-s", "/ihme/malaria_modeling/dtcitron/SpatialUncertainty/Baseline_job_script.R")
  
  args = c(i) # this is a seed, passed to the initial conditions of the simulation
  
  # Here's the text of the qsub call
  print(paste(sys.sub, shell, script, "\\", args))
  
  # And we can call the qsub as if it were from the command line here:
  system(paste(sys.sub, shell, script, "\\", args))
}