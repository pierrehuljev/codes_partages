####### Plot parameters influence on Krs #########

##### Setting parameters and loop your simulations

taproot_radius <- c(0.1,0.2,0.3)
dist_ram <- c(0.1,0.2,0.3)
max_length_long_lat <- c(10,20,30)
#[loop and make hydraulics archi with krs parameter corresponding]

##### Then plot for each parameter

#example for the diameter of the taproot :

all_rootsystems %>%
  ggplot(aes(taproot_radius  ,krs, colour = krs)) +
  geom_point()

##### If you want to plot for 2 parameters an see the combine influence on the Krs 

#example for the influence of the distance between ramifications and the maximum length of the lateral roots :

all_rootsystems %>%
  ggplot(aes(dist_ram, max_length_long_lat, colour = krs)) +
  geom_point() 

##### If now you want to see the influence on Krs for tree parameters in one graph

# you can plot like this example with a facet wrap : 

all_rootsystems %>%
  ggplot(aes(dist_ram,max_length_long_lat, colour = krs)) +
  geom_point() + 
  facet_wrap(vars(taproot_radius))

# Or you can also use a facet grid : 

all_rootsystems %>%
  ggplot(aes(dist_ram,max_length_long_lat, colour = krs)) +
  geom_point() + 
  facet_grid(.~taproot_radius) 

