---
title: "Read_Me"
author: "Van Asbrouck Lison"
date: "2024-05-15"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Link between MARSHAL and APSIM based on Krs and Kl

### Explaination

There is a link between the Krs which you can calculate with MARSHAL and the Kl parameter which is used in APSIM.

To make this link, you just have to take the ratio between your calculated Krs and the standard Krs and make the exactly same ratio with the standard Kl to obtain your calculate Kl linked to the Krs.

Pay attention, the values used have to be verified.

Once you have theses parameters, you can make a dataframe with your MARSHAL parameters which you are testing, the Krs linked to them and your Kl calculated with theses Krs.

With this dataframe in input and the other fixed parameters for APSIM, you can run the loop which will run APSIM for each line of your input dataframe with your MARSHAL parameters that you want to test.

You will have in output a dataframe with all the 30 days of the running APSIM for each combine of parameters.

### Plots you will be able to do

With the output dataframe, you will be able to make a plot of the evolution of the biomass for each value of your tested parameter. For example, I have put in the codes_partages a plot obtained with this output which link the different radius to the evolution of Biomass (there is a line for each repetition).
