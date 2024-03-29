#TITLE, INTRODUCTION, AND QUESTIONS####

#Written by Ian Spence - October 4, 2019. 

          #Odonata Data Analysis: Locating Canadian Diversity


  #Odonata is an order of insect containing Dragonflies and Damselflies which may provide useful insight into the health of an ecosystem.  In an effort to document the biodiversity of this order, we want to know where in Canada sampling efforts should be concentrated to increase sample coverage of unique BIN entries.  By determining AT proportions (a marker of genetic diversity) across well sampled provinces, we can determine a candidate province to send our conservation team to collect and publish more Odonata data! (And metadata!).  Before this type of expedition would take place, more intraprovincial data could be analyzed such as known range, climatic regions, current sample locations, and more.  This is a preliminary analysis to direct further research.


          #THE QUESTION(s)

#First, is the data published on BOLD sufficient to draw conclusions about where in Canada to direct Odonata sampling efforts?

  #If so, which well sampled province is most likely to yield novel Odonata biodiversity from sampling? 


#LOAD (AND INSTALL) PACKAGES####

#First, we can load packages to manage and manipulate our data. 

library(tidyverse)
library(vegan)
library(dplyr)
library(DECIPHER)
library(muscle)
library(Biostrings)
library(ape)
library(RSQLite)
library(iNEXT)
library(ggplot2)

#If any packages are not installed, enter their name into the following function first(remove the #).
#install.packages()

#GLOBAL VS CANADIAN DATASETS####


#Now, read in the data from BOLD. This file was downloaded on October 4, 2019.

#This file make takes 3-4 minutes to load.

Odonata <- read_tsv("http://www.boldsystems.org/index.php/API_Public/combined?taxon=Odonata&format=tsv")


#What does our data include?
summary(Odonata)

#What are the names of the variables?
names(Odonata)


#Let's compare the rarefaction curves between global Odonata samples to Canadian Odonata samples.


#Make a dataframe of the count of each unique BIN from around the world. 

BIN.Count <- data.frame(table(Odonata$bin_uri))


#Change the column names to "BIN" and "Frequency".

BIN.Var <- c("BIN", "Frequency")
colnames(BIN.Count) <- BIN.Var


#Spread the BIN column to produe community data where variables are entries collected in a single location.

BIN.Spr <- spread(BIN.Count, "BIN", "Frequency")


#Construct a rarefaction curve.  We want the ylab argument to be set to "BIN Frequency", the default is "Species".

rarecurve(BIN.Spr, ylab = "BIN Frequency")


#See how the global samples from across the world.  BIN Frequency is still increasing as sample size increases.  Now let's look at the same type curve but with Canadian data. 


#Seperate Canadian samples from the global samples. 

C.BIN <- Odonata %>%
  filter(country == "Canada")


#Make a dataframe of the count of each unique BIN from Canada. 

C.BIN.Count <- data.frame(table(C.BIN$bin_uri))


#Change the column names to "BIN" and "Frequency".

C.BIN.Var <- c("BIN", "Frequency")

colnames(C.BIN.Count) <- C.BIN.Var


#Spread the BIN column to produce community data where variables are BIN entries collected in a single location.

C.BIN.Spr <- spread(C.BIN.Count, "BIN", "Frequency")


#Construct a rarefaction curve.  We want the ylab argument to be set to "BIN Frequency", the default is "Species".

rarecurve(C.BIN.Spr, ylab = "BIN Frequency")


#The rarefaction curve of Canadian data ends up flatter than the rarefaction curve of global data. In determining a place to look for diverse Odonata samples, Canada might not be the first option.  It is however well represented and because the conservation expedition can't leave the country, we will now determine where in Canada is the best place to look for more.

#PROVINCIAL AT PROPORTIONS####


#Which provinces have the Odonata entries with the greatest variation in AT proportions compared to the national average?


#Before choosing provinces, filter out the following samples by:  
#BIN NAs, Province NAs, missing nucleotide data, or anything without COI-5P as the markercode.

BIN.Prov <- Odonata %>%
  filter(!is.na(Odonata$bin_uri)) %>%
  filter(country == "Canada") %>%
  filter(!is.na(province_state)) %>%
  filter(str_detect(nucleotides, "[ACGT]"))


#Check how many provinces have a well represented number of samples.  We'll use 100 samples as our cutoff. 

table(C.BIN$province_state)


#Looks like six provinces have 100+ samples.  Let's analyze the nucleotide data in each of these six datasets. 

#First, turn our nucleotides into Biostrings.

BIN.Prov$nucleotides <- DNAStringSet((BIN.Prov$nucleotides))


#Now determine the mean AT proportion for each of the six provinces to be analyzed.  

#Determine the nucleotide frequencies.

BC.NucFreq <- as.data.frame(letterFrequency(BIN.Prov$nucleotides, letters = c("A", "C", "G", "T", "N"))) %>%
  filter(BIN.Prov$province_state == "British Columbia")


#Filter out any samples with Ns present. 

BC.NucFreq <- BC.NucFreq %>%
  filter(BC.NucFreq$N == 0)


#Add another column with the AT proportion. 

BC.AT.Prop <- BC.NucFreq %>%
  mutate(ATproportion = ((A + T) / (A + T + G + C)))


#Determine the mean of AT proportions across all samples from BC. 

BC.AT.mean <- mean(BC.AT.Prop$ATproportion)



#Repeat for all six provinces above the 100 sample threshold we have set. 

#Commenting is the same as it was in BC for all other provinces. 


#Alberta

AB.NucFreq <- as.data.frame(letterFrequency(BIN.Prov$nucleotides, letters = c("A", "C", "G", "T", "N"))) %>%
  filter(BIN.Prov$province_state == "Alberta")

AB.NucFreq <- AB.NucFreq %>%
  filter(AB.NucFreq$N == 0)

AB.AT.Prop <- AB.NucFreq %>%
  mutate(ATproportion = ((A + T) / (A + T + G + C)))

AB.AT.mean <- mean(AB.AT.Prop$ATproportion)


#Manitoba

MN.NucFreq <- as.data.frame(letterFrequency(BIN.Prov$nucleotides, letters = c("A", "C", "G", "T", "N"))) %>%
  filter(BIN.Prov$province_state == "Manitoba")

MN.NucFreq <- MN.NucFreq %>%
  filter(MN.NucFreq$N == 0)

MN.AT.Prop <- MN.NucFreq %>%
  mutate(ATproportion = ((A + T) / (A + T + G + C)))

MN.AT.mean <- mean(MN.AT.Prop$ATproportion)


#New Brunswick

NB.NucFreq <- as.data.frame(letterFrequency(BIN.Prov$nucleotides, letters = c("A", "C", "G", "T", "N"))) %>%
  filter(BIN.Prov$province_state == "New Brunswick")

NB.NucFreq <- NB.NucFreq %>%
  filter(NB.NucFreq$N == 0)

NB.AT.Prop <- NB.NucFreq %>%
  mutate(ATproportion = ((A + T) / (A + T + G + C)))

NB.AT.mean <- mean(NB.AT.Prop$ATproportion)


#Ontario

ON.NucFreq <- as.data.frame(letterFrequency(BIN.Prov$nucleotides, letters = c("A", "C", "G", "T", "N"))) %>%
  filter(BIN.Prov$province_state == "Ontario")

ON.NucFreq <- ON.NucFreq %>%
  filter(ON.NucFreq$N == 0)

ON.AT.Prop <- ON.NucFreq %>%
  mutate(ATproportion = ((A + T) / (A + T + G + C)))

ON.AT.mean <- mean(ON.AT.Prop$ATproportion)


#Saskatchewan

SK.NucFreq <- as.data.frame(letterFrequency(BIN.Prov$nucleotides, letters = c("A", "C", "G", "T", "N"))) %>%
  filter(BIN.Prov$province_state == "Saskatchewan")

SK.NucFreq <- SK.NucFreq %>%
  filter(SK.NucFreq$N == 0)

SK.AT.Prop <- SK.NucFreq %>%
  mutate(ATproportion = ((A + T) / (A + T + G + C)))

SK.AT.mean <- mean(SK.AT.Prop$ATproportion)



#Great, now let's calculate the mean AT proportion across Canada so we can compare these provinces to determine where the most diverse groups may be located.

#The commenting for the following is the same except there in no need to filter by province as we want data from the whole country. 


Can.Nuc.Freq <- as.data.frame(letterFrequency(BIN.Prov$nucleotides, letters = c("A", "C", "G", "T", "N")))

  Can.Nuc.Freq <- Can.Nuc.Freq %>%
  filter(Can.Nuc.Freq$N == 0)

  Can.AT.Prop <- Can.Nuc.Freq %>%
    mutate(ATproportion = ((A + T) / (A + T + G + C)))
  
  Can.AT.mean <- mean(Can.AT.Prop$ATproportion)

  
  
#Let's determine the provinces with the largest difference in mean AT proportion compared to the Canadian dataset.  
  

#Make a vector with the mean AT proportion of the provinces.

Prov.AT.Data <- data.frame(AB.AT.mean, BC.AT.mean, MN.AT.mean, ON.AT.mean, SK.AT.mean, NB.AT.mean, Can.AT.mean)


#Now, determine the difference in AT proportion between each province and the national mean.

AB.Dif <- AB.AT.mean - Can.AT.mean
BC.Dif <- BC.AT.mean - Can.AT.mean
MN.Dif <- MN.AT.mean - Can.AT.mean
ON.Dif <- ON.AT.mean - Can.AT.mean
SK.Dif <- SK.AT.mean - Can.AT.mean
NB.Dif <- NB.AT.mean - Can.AT.mean

#Make a vector with all province difference values. 

Prov.Dif <- c(AB.Dif, BC.Dif, MN.Dif, ON.Dif, SK.Dif, NB.Dif)

#Check the max, ie. the province with the greatest relative AT proportion to the national mean.
Prov.Dif
which.max(Prov.Dif)

#check the min, ie. the province with the lowest relative AT proportion to the national mean.

which.min(Prov.Dif)

#We can see that of the provinces with the highest and lowest mean AT proportions are 1 and 6, or AB and NB. 

#Let's check if our results could have happened by chance or not.

#Is the AT proportion of British Columbia significantly different than that of Canada?

t.test(AB.AT.Prop$ATproportion, Can.AT.Prop$ATproportion)

#Yes, it is.
#Is the AT proportion of New Brunswick significantly different than that of Canada?

t.test(NB.AT.Prop$ATproportion, Can.AT.Prop$ATproportion)

#Yes.  It's also significant. 



#Let's clean up the environment and explore these two provinces more.  


rm(AB.AT.Prop, BC.AT.Prop, MN.AT.Prop, NS.AT.Prop, NW.AT.Prop, ON.AT.Prop, QB.AT.Prop, PE.AT.Prop, SK.AT.Prop, YK.AT.Prop, NB.AT.Prop, AB.NucFreq, BC.NucFreq, MN.NucFreq, NS.NucFreq, NW.NucFreq, ON.NucFreq, QB.NucFreq, PE.NucFreq, SK.NucFreq, YK.NucFreq, NB.NucFreq, AB.AT.mean, BC.AT.mean, MN.AT.mean, NS.AT.mean, NW.AT.mean, ON.AT.mean, QB.AT.mean, PE.AT.mean, SK.AT.mean, YK.AT.mean, NB.AT.mean, BIN.Var, C.BIN.Var, C.BIN, BIN.Prov, BIN.Spr, C.BIN.Spr, AB.Dif, BC.Dif, MN.Dif, NB.Dif, ON.Dif, SK.Dif, Can.AT.Prop, Can.Nuc.Freq, Prov.AT.Data, Can.AT.mean, Prov.Dif, BIN.Count, C.BIN.Count)





#EXTRAPOLATION TO DETERMINE BEST PROVINCE####

#Now let's use the interpolation and extrapolation function iNEXT.  We can compare data between each province to direct us to which province is best for our trip to discover diverse Odonata samples.  iNEXT allows us to enter the calculation into ggplot so we can visualize the sample coverage data. 

#First determine the sample coverage in Alberta.

#Filter the original Odonata dataset for AB samples with a BIN entry.

AB.Dataset <- Odonata %>%
  filter(!is.na(Odonata$bin_uri)) %>%
  filter(province_state == "Alberta")


#Further subset the data to only contain the BIN_uri column, column 8.

AB.BINs <- AB.Dataset[, 8]


#Name this column "Freq".

colnames(AB.BINs) <- "Freq"


#Create a data frame listing the frequency of unique BINs in AB. 

AB.BIN.Freq <- data.frame(table(AB.BINs$Freq))


#Change this into an atomic vector. 

AB.BIN.Freq.Only <- AB.BIN.Freq$Freq


#Apply the iNEXT function to the AB BIN Frequency.

iNEXT(AB.BIN.Freq.Only, )

#Now let's plot this data using ggiNEXT.  First, put the iNEXT output into an object.

AB.BIN.i <- iNEXT(AB.BIN.Freq.Only, )

#Plot this using ggiNEXT.  Our arguments are set to project the number of potential unique BIN entries that have yet to be sampled and the number of samples required to uncover these unique BINs.

ggiNEXT(x = AB.BIN.i, type = 1) + theme_linedraw(base_size = 18, base_rect_size = 1)


#Great. Now we'll do the same for New Brunswick and compare the two. 


#Filter the original Odonata dataset for New Brunswick samples with a BIN entry.

NB.Dataset <- Odonata %>%
  filter(!is.na(Odonata$bin_uri)) %>%
  filter(province_state == "New Brunswick")


#Further subset the data to only contain the BIN_uri column, column 8.

NB.BINs <- NB.Dataset[, 8]


#Name this column "Freq".

colnames(NB.BINs) <- "Freq"


#Create a data frame listing the frequency of unique BINs in NB. 

NB.BIN.Freq <- data.frame(table(NB.BINs$Freq))


#Change this into an atomic vector.

NB.BIN.Freq.Only <- NB.BIN.Freq$Freq


#Apply the iNEXT function to the NB BIN Frequency.

iNEXT(NB.BIN.Freq.Only, )

#Let's plot this data using ggiNEXT.  First, put the iNEXT output into an object.

NB.BIN.i <- iNEXT(NB.BIN.Freq.Only, )

#Plot this using ggiNEXT.  Our arguments are set to project the number of potential unique BIN entries that have yet to be sampled and the number of samples required to uncover these unique BINs.

ggiNEXT(x = NB.BIN.i, type = 1) + theme_linedraw(base_size = 18, base_rect_size = 1)

#Great.  Let's analyze the results of our plots.  

#Although ggiNEXT is superior to rarecurve for visualization, it doesn't offer the same argument to change the y axis as the rarecurve function has.  It is important to note that these charts are designed for species diversity rather than BIN diversity. 

#By extrapolating the number of new BIN entries if we doubled our sample size using iNEXT, we can determine which province is better to travel to, to sample diverse Odonata specimens.  The New Brunswick chart looks as though about another 18 new BINs will be identified in the next 622 samples.  By entering the back arrow in the display window, we can revert to viewing the Alberta chart. The Alberta data looks as though another 6 BINs will be identified in the next 150 samples. These calculations suggest a similar number of unique BIN samples may be collected with about 72% of the samples size in Alberta compared to New Brunswick.  Additionally, these potential samples may vary further from the national mean than samples collected in New Brunswick. The Alberta sampled AT proportions varied further from the national mean than the New Brunswick samples did, their values being 0.0066956174 and -0.0049306069 respectively.  Looks like we're going to Alberta!


#The data was downloaded from BOLD on October 4th, 2019. 

#Ratnashigham S., Hebert, P.D.N. (2007). BOLD: The Barcode of Life Data System (www.barcodinglife.org).  Molecular ecology notes 7(3): 355-364. [8]

#The iNEXT function was found at:

#Hsieh T.C., Ma K.H., Chao, A. (2019). A Quick Introduction to iNEXT via Examples. https://cran.r-project.org/web/packages/iNEXT/vignettes/Introduction.html [9]


