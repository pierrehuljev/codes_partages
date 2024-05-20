
#########################################################
############# LINK BETWEEN MARSHAL AND APSIM ############
##################### BY KRS AND KL #####################
#########################################################


# Krs and Kl ratio

kl_std = (0.06+0.05+0.05)/3
krs_std = 0.06938548

# Dataframe 
correspondance_full <- data.frame(radius = c(all_rootsystems$taproot_radius),
                                  krs_radius = c(all_rootsystems$krs),
                                  kl_radius = c(kl_std*(all_rootsystems$krs/krs_std)),
                                  stringsAsFactors = FALSE)   # Don't convert strings to factors!

correspondance <- unique(correspondance_full)

print(correspondance)

# Insert [fixed_parameters_for_APSIM (pay attention, you don't have to put the kl parameters here')]

# Loop for APSIM for each parameters of MARSHAL

for (line in 1:(nrow(correspondance))){
  
  radius <- correspondance$radius[line]
  krs <- correspondance$krs_radius[line]
  kl1 <- correspondance$kl_radius[line]
  kl2 <- kl1
  kl3 <- kl1
  
  sim_one <- data.frame(radius = c(radius), rep = c(mod(line-1,3)+1), krs = c(krs), das = c(tinit)) %>% 
    mutate(root_depth = ifelse(das * RootGrowthRate < totDepth,
                               das * RootGrowthRate , 
                               totDepth)) %>% 
    mutate(ASW1 = input$initASW1, 
           ASW2 = input$initASW2, 
           ASW3 = input$initASW3) %>% 
    mutate(totASW = ASW1 + ASW2 + ASW3) %>% 
    
    mutate(ps1 = ifelse(root_depth >= depth1,
                        1 * ASW1 * kl1, 
                        (root_depth / depth1) * ASW1 * kl1)) %>% 
    mutate(ps2 = ifelse(root_depth <= depth1,
                        0, 
                        ifelse(root_depth > depth1+depth2,
                               1 * ASW2 * kl2, 
                               ((root_depth-depth1) / depth2) * ASW2 * kl2))) %>% 
    mutate(ps3 = ifelse(root_depth <= depth1+depth2, 
                        0, 
                        ((root_depth - depth1 - depth2)/depth3) * ASW3 * kl3)) %>% 
    mutate(potsupply = ps1 + ps2 + ps3) %>% 
    mutate(lai = InitialLAI) %>% 
    mutate(li = 1 - exp(-k*lai)) %>% 
    mutate(potdemand = meteo$Radn[meteo$DAS == das] * li * RUE / 
             (TEc / (meteo$VPDcalc[meteo$DAS == das]/10))) %>% 
    mutate(sd = potsupply / potdemand) %>% 
    mutate(leafexpeffect = ifelse( sd <= sd1, 
                                   0, 
                                   ifelse(sd > sd2,
                                          1, 
                                          (sd - sd1)/(sd2-sd1)))) %>% 
    mutate(Dlai = leafexpeffect * PotentialDLAI) %>% 
    mutate(transpiration = min(potdemand, potsupply)) %>% 
    mutate(SWaterUse = transpiration) %>% 
    mutate(BioWater = potsupply * TEc / (meteo$VPDcalc[meteo$DAS == das]/10)) %>% 
    mutate(BioLight = meteo$Radn[meteo$DAS == das] * li * RUE) %>% 
    mutate(DBiomass = ifelse(sd > 1, BioLight, BioWater)) %>% 
    mutate(biomass = DBiomass + InitialBiomass)
  
  
  # Update dataframe 
  
  rewater <- 0
  for(i in c((tinit+1):(tmax))){
    #for (i in correspondance['radius']){
    
    tempP <- sim_one[sim_one$das == i-1,]
    # tempP <- correspondance[correspondance$radius == i-1]
    temp <- tempP %>% mutate(das = i)
    # temp <- tempP %>% mutate(radius = i)
    
    # temp$radius <- correspondance$radius
    # temp$krs <- correspondance$krs_radius
    temp$ASW1 <- tempP$ASW1-(tempP$ps1/tempP$potsupply)*tempP$transpiration
    temp$ASW2 <- tempP$ASW2-(tempP$ps2/tempP$potsupply)*tempP$transpiration
    temp$ASW3 <- tempP$ASW3-(tempP$ps3/tempP$potsupply)*tempP$transpiration
    
    if(i == rewater){
      temp$ASW1 <- soils$ASW1[soils$type == "wet"]
      temp$ASW2 <- soils$ASW2[soils$type == "wet"]
      temp$ASW3 <- soils$ASW3[soils$type == "wet"]
      rewater = rewater + input$rewater
      print(paste0("rewater ",rewater))
    }
    
    temp <- temp %>%
      mutate(root_depth = ifelse(das * RootGrowthRate < totDepth,
                                 das * RootGrowthRate , 
                                 totDepth)) %>% 
      mutate(totASW = ASW1 + ASW2 + ASW3) %>% 
      mutate(ps1 = ifelse(root_depth >= depth1,
                          1 * ASW1 * kl1, 
                          (root_depth / depth1) * ASW1 * kl1)) %>% 
      mutate(ps2 = ifelse(root_depth <= depth1,
                          0, 
                          ifelse(root_depth > depth1+depth2,
                                 1 * ASW2 * kl2, 
                                 ((root_depth-depth1) / depth2) * ASW2 * kl2))) %>% 
      mutate(ps3 = ifelse(root_depth <= depth1+depth2, 
                          0, 
                          ((root_depth - depth1 - depth2)/depth3) * ASW3 * kl3)) %>% 
      mutate(potsupply = ps1 + ps2 + ps3) %>% 
      mutate(lai = tempP$lai + tempP$Dlai) %>% 
      mutate(li = 1 - exp(-k*lai)) %>% 
      mutate(potdemand = meteo$Radn[meteo$DAS == das] * li * RUE / 
               (TEc / (meteo$VPDcalc[meteo$DAS == das]/10))) %>% 
      mutate(sd = potsupply / potdemand) %>% 
      mutate(leafexpeffect = ifelse( sd <= sd1, 
                                     0, 
                                     ifelse(sd > sd2,
                                            1, 
                                            (sd - sd1)/(sd2-sd1)))) %>% 
      mutate(Dlai = leafexpeffect * PotentialDLAI) %>% 
      mutate(transpiration = min(potdemand, potsupply)) %>% 
      mutate(SWaterUse = transpiration + tempP$SWaterUse) %>% 
      mutate(BioWater = potsupply * TEc / (meteo$VPDcalc[meteo$DAS == das]/10)) %>% 
      mutate(BioLight = meteo$Radn[meteo$DAS == das] * li * RUE) %>% 
      mutate(DBiomass = ifelse(sd > 1, BioLight, BioWater)) %>% 
      mutate(biomass = DBiomass + tempP$biomass)
    
    sim_one <- rbind(sim_one, temp)
    print(line)
  }
  if (line == 1) {
    sim_all <- data.frame(sim_one)
  }
  else {
    sim_all <- rbind(sim_all, sim_one)
  }
}
#}