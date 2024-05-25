
#########################################################
############# LINK BETWEEN MARSHAL AND APSIM ############
##################### BY Transpiration ##################
#########################################################

#For a loam soil

theta_s <- 0.3991 # [cm^3/cm^3]
theta_r <- 0.0609 # [cm^3/cm^3]
alpha <- 0.0111 # [cm^-1]
n <- 1.4737 # [-]
m <- 1 - 1/n # [-]

fonction_van_genuchten <- function (psi) {
  #Computes the water retention, theta, for a given value of psi using the van Genuchten model.
  #Args: psi:   The soil suction/soil water potential (psi_m) expressed in [cm] or in [hPa]. Default is [cm].
  #Returns: Theta, the water retention corresponding to the given psi and is expressed in [cm^3/cm^3].
  
  theta <- theta_r + ((theta_s - theta_r)/(1+(alpha*abs(psi))^n)^m)
  
  return(theta)
}

fonction_inv_van_genuchten <- function(theta){
  # Computes the soil suction/soil water potential for a given water content, theta, expressed in [cm^3/cm^3].
  #Args: theta,  Water content in cm^3/cm^3.
  # Returns: Psi, the soil water potential in [cm of water].
  
  psi <- (((((theta_s - theta_r)/(theta - theta_r))^(1/m))-1)^(1/n))*(- 1/alpha)
  
  return(psi)
}

psi_1 <- fonction_inv_van_genuchten(input$initASW1/400)
psi_2 <- fonction_inv_van_genuchten(input$initASW2/400)
psi_3 <- fonction_inv_van_genuchten(input$initASW3/400)

#j_MPa <- j*0.980655*1*10^-4

psi_all_cm <- c(psiCollar/(0.980655*1*10^-4), psi_1 , psi_2, psi_3) 

theta_all_MPa <- psi_all_cm*0.980655*1*10^-4 #Transformation en MPa

id <- c(1, 2, 3, 4)
z <- c(0, -40, -80, -120)

soil_psi_boucle <- data.frame(id= id, z = z, psi = theta_all_MPa)

hydraulics_local <- getSUF(current_rootsystem, conductivities, soil_psi_boucle, psiCollar)

hydraulic_local_archi <- hydraulics_local$root_system
hydraulic_local_archi$suf <- hydraulics_local$suf[,1]
hydraulic_local_archi$kr <- hydraulics_local$kr[,1]
hydraulic_local_archi$kx <- hydraulics_local$kx[,1]
hydraulic_local_archi$jr <- hydraulics_local$jr[,1]
hydraulic_local_archi$jxl <- hydraulics_local$jxl[,1]
hydraulic_local_archi$psi <- hydraulics_local$psi[,1]
print(paste0("KRS = ",hydraulics_local$krs))
print(paste0("Potential transpiration = ",hydraulics_local$tpot))#
print(paste0("Actual transpiration = ",hydraulics_local$tact))
#Pour exprimer cette transpiration en mm/jour sachant que j'ai des cm^3/jour.plante (8plantes/m^2)
transpi_p <- hydraulics_local$tact*0.0008
transpi_init <- transpi_p*10
print(transpi_init)

# Initialise dataframe
sim <- data.frame(das = c(tinit)) %>% 
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
  mutate(transpiration_marshal = transpi_init) %>%
  #Comparaison entre transpiration marshal (qui est le maximum que la plante peut faire) et la transpi apsim
  mutate(transpiration = ifelse(transpi_init<min(potdemand, potsupply),transpi_init,min(potdemand,potsupply))) %>% 
  mutate(SWaterUse = transpiration) %>% 
  mutate(BioWater = potsupply * TEc / (meteo$VPDcalc[meteo$DAS == das]/10)) %>% 
  mutate(BioLight = meteo$Radn[meteo$DAS == das] * li * RUE) %>% 
  mutate(DBiomass = ifelse(sd > 1, BioLight, BioWater)) %>% 
  mutate(biomass = DBiomass + InitialBiomass)



rewater <- 0
for(i in c((tinit+1):(tmax))){
  
  tempP <- sim[sim$das == i-1,]
  temp <- tempP %>% mutate(das = i)
  
  temp$ASW1 <- tempP$ASW1-(tempP$ps1/tempP$potsupply)*tempP$transpiration
  temp$ASW2 <- tempP$ASW2-(tempP$ps2/tempP$potsupply)*tempP$transpiration
  temp$ASW3 <- tempP$ASW3-(tempP$ps3/tempP$potsupply)*tempP$transpiration
  
  if(i == rewater){
    temp$ASW1 <- soils$ASW1[soils$type == "dry"]
    temp$ASW2 <- soils$ASW2[soils$type == "dry"]
    temp$ASW3 <- soils$ASW3[soils$type == "dry"]
    rewater = rewater + input$rewater
    print(paste0("rewater ",rewater))
  }
  
  theta_1_cm <- temp$ASW1
  theta_2_cm <- temp$ASW2
  theta_3_cm <- temp$ASW3
  
  psi_1_cm <- fonction_inv_van_genuchten(theta_1_cm/400)
  psi_2_cm <- fonction_inv_van_genuchten(theta_2_cm/400)
  psi_3_cm <- fonction_inv_van_genuchten(theta_3_cm/400)
  
  psi_1_MPa <- psi_1_cm*0.980655*1*10^-4
  psi_2_MPa <- psi_2_cm*0.980655*1*10^-4
  psi_3_MPa <- psi_3_cm*0.980655*1*10^-4
  
  new_values <- c(psiCollar,psi_1_MPa, psi_2_MPa, psi_3_MPa)
  
  soil_psi_boucle[3] <- new_values
  
  hydraulics_local <- getSUF(current_rootsystem, conductivities, soil_psi_boucle, psiCollar)
  
  hydraulic_local_archi <- hydraulics_local$root_system
  hydraulic_local_archi$suf <- hydraulics_local$suf[,1]
  hydraulic_local_archi$kr <- hydraulics_local$kr[,1]
  hydraulic_local_archi$kx <- hydraulics_local$kx[,1]
  hydraulic_local_archi$jr <- hydraulics_local$jr[,1]
  hydraulic_local_archi$jxl <- hydraulics_local$jxl[,1]
  hydraulic_local_archi$psi <- hydraulics_local$psi[,1]
  
  print(paste0("KRS = ",hydraulics_local$krs))
  print(paste0("Potential transpiration = ",hydraulics_local$tpot))
  print(paste0("Actual transpiration = ",hydraulics_local$tact))
  #Pour exprimer cette transpiration en mm/jour sachant que j'ai des cm^3/jour.plante (8plantes/m^2)
  transpi_act <- hydraulics_local$tact*0.0008
  transpi <- transpi_act*10
  print(transpi)
  
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
    mutate(transpiration_marshal = transpi) %>%
    mutate(transpiration = ifelse(transpi<min(potdemand, potsupply),transpi,min(potdemand, potsupply))) %>% 
    mutate(SWaterUse = transpiration + tempP$SWaterUse) %>% 
    mutate(BioWater = potsupply * TEc / (meteo$VPDcalc[meteo$DAS == das]/10)) %>% 
    mutate(BioLight = meteo$Radn[meteo$DAS == das] * li * RUE) %>% 
    mutate(DBiomass = ifelse(sd > 1, BioLight, BioWater)) %>% 
    mutate(biomass = DBiomass + tempP$biomass)
  
  sim <- rbind(sim, temp)
}