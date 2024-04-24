# FONCTION INITIALISATION ---------------------------------------------------------------------
# Root volume 
root_volume_calculation <- function(rootsystem){
  
  # Volume of each segment of root (considering a cylindric root)
  segment_volume <- pi * rootsystem$radius^2 * rootsystem$length
  
  # Sum of all segment
  volume <- sum(segment_volume)
  
  return(volume)
}

# Z_{SUF} 
ZSUF_calculation <- function(hydraulics){
  
  # depth*SUF for each segment of root
  segment_SUF <- hydraulics$root_system$z2 * hydraulics$suf
  
  # Sum of all segment
  ZSUF <- sum(segment_SUF)
  
  return(ZSUF)
}



