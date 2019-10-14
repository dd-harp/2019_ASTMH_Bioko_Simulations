####
# Clean Raw Data - Aggregate travel data by pixel
#
# Load in the summary of the 2018 MIS travel data
# contained in the file data/raw/mis2018travel
# Aggregate it together by areaId
#
# August 12, 2019
#
####

# Load libraries ####
library(data.table)
library(here)

# Load data ####
mis.raw <- fread(here("data/raw/2018_travel_data/mis2018travel.csv"))
#mis.raw <- mis.raw[,c("areaId", "travelledisland", "travelledEG")]

# Open data set for catching trip counts data ####
travel.data.2018 <- data.table(areaId = sort(unique(mis.raw$areaId)))
# Count the total number of people interviewed in each areaId in 2018:
travel.data.2018 <- merge(travel.data.2018, mis.raw[, .(n = .N), by = areaId], by = "areaId", all = TRUE)

# Travel frequency ####
# For each areaID, find the number of people who left home
travel.data.2018 <- merge(travel.data.2018, mis.raw[travelledisland == "yes" | travelledEG == "yes", .(counts = .N), by = areaId, ],
      by = "areaId", all= TRUE)
travel.data.2018[is.na(counts)]$counts <- 0

# For each areaID, find the number of people who left home to go elsewhere on the island
travel.data.2018 <- merge(travel.data.2018, mis.raw[travelledisland == "yes", .(counts.bi = .N), by = areaId, ],
      by = "areaId", all= TRUE)
travel.data.2018[is.na(counts.bi)]$counts.bi <- 0

# For each areaID, find the number of people who left home to go to the mainland
travel.data.2018 <- merge(travel.data.2018, mis.raw[travelledEG == "yes", .(counts.eg = .N), by = areaId, ],
                          by = "areaId", all= TRUE)
travel.data.2018[is.na(counts.eg)]$counts.eg <- 0


# Probability distribution across destinations ####
# The data here are not necessarily commensurate with the trip counts from the other raw data set
# Namely, not everybody reported their high-resolution detailed travel information 
# (ie, they say they traveled but did not say where).  In these cases, there can be fewer 
# travel events reported in the high resolution data than in the low resolution data.
# Additionally, some people took multiple trips.  In these cases, there can be more
# travel events reported in the low resolution data than in the high resolution data.

# The high resolution data lists the destination at the ad4 level, but we will want the destination at the ad2 level <- <-  <- <- <- <- <- <- <- <- <- 

# not that difficult to find ureka, or moka <- <-  <- <-  <- <- <- <- <-  <- <- <- <-  <- <-  <- <- <- <- <-  <- <- <- <- <- # we can just count trips to these two places as trips to "Moka"

# Read in the off-island travel data #### <- <-  <-  <-  <-  <- <- <- <- <- <-  <- <-  <- <-  <- <- <- # Read in the on-island travel data ####
bi.trips <- fread(here("data/raw/2018_travel_data/trips_on_BI.csv"))
# now we need to map the ad4 units onto ad2 units
# first read in ad4 shapefile
library(raster)
library(maptools)
library(rgdal)
ad4 <- rgdal::readOGR(here("data/raw/admin4shp/admin4V19.shp"))
ad4.2.ad2 <- as.data.table(ad4[,c("admin2", "admin2ID", "admin4ID")])
colnames(ad4.2.ad2) <- c("admin2", "admin2Id", "admin4Id")
# now merge to include ad2 destinations
bi.trips <- merge(bi.trips, ad4.2.ad2, by = "admin4Id")
# create a separate column for destination region
bi.trips$dest.reg <- bi.trips$admin2
# now we designate certain destination ad4's as Moka and Ureka
# Ureka's ad4 ids: L260 ("Ureka") - 2 surveyed
# mis.raw[community == "Ureka", c("community", "admin4ID")
# Moka's ad4 ids: L184 ("Moka Malabo") - 77 surveyed
# mis.raw[community == "Moka Malabo", c("community", "admin4ID")]
# L266 (Moka Bioko) - 231 surveyed
# mis.raw[community == "Moka Bioko", c("community", "admin4ID")]
bi.trips[admin4Id == "L260"]$dest.reg <- "Ureka"
bi.trips[admin4Id %in% c("L184", "L266")]$dest.reg <- "Moka"

# Transform data: count number of trips for each areaId to each destination region
holder <- bi.trips[, c("areaId", "dest.reg")]
holder <- dcast(holder, areaId ~ dest.reg, length)

# Put everything together
travel.data.2018 <- merge(travel.data.2018, holder, by = "areaId", all = TRUE)
travel.data.2018[is.na(travel.data.2018)] <- 0

colnames(travel.data.2018) <- c("areaId", "n.2018", "trip.counts.2018", "trip.counts.bi.2018", "trip.counts.eg.2018",
                                "to.2018", "ti_ban.2018", "ti_lub.2018", "ti_mal.2018", "ti_ria.2018", "ti_ure.2018", "ti_mok.2018")
# count the total number of trips with high-resolution data
travel.data.2018[,trip.counts.res.2018:=sum(to.2018, ti_ban.2018, ti_lub.2018, ti_mal.2018, ti_ria.2018, ti_ure.2018, ti_mok.2018), by = "areaId"]
# trip.counts.res.2018 - this column will be used as the denominator for when we fit the destination choice model

# Combine with 2015-2017 travel data ####
# The next steps will involve piping this data set in to
# 1) The travel frequency model, adding the data together with the 2015-2017 data
# 2) The destination choice model, adding the data together with the 2015-2017 data
#
# One big problem with doing it this way is that both of these data sets are unevenly sampled
# The missing data means that we've lost a bunch of information
# What if we assume that the data that were dropped from the high resolution data sets
# were unbiased, meaning that these other data are a smaller subset of the data?
# But how does that let us set the right denominators?
#
# The two questions we are asking: 
# 1) how frequently do people leave? <- this we can get from the mis2018 dat
# 2) what's the probability distribution of them going to each location? <- this
# we can get from the (we hope evenly) subsampled trips for which we do have
# destination locations
#
# We need to be really, really careful with this next part:
# The "n" in travel.data.2015-2017 includes *all* people surveyed
# The "n" in travel.data.2018 includes *all* people surveyed
# The "ti_mal" in travel.data.2015-2017 includes *all* travelers to malabo
# The "ti_mal" in travel.data.2018 includes only a subset.

# Load in travel data from 2015-2017 and reformat
travel.data.2015.2017 <- fread(here("data/raw/2015-2017_survey_data/summaries.csv"))
travel.data.2015.2017 <- travel.data.2015.2017[,c("areaId", "ad2", "n", "to", "ti_ban", "ti_lub", "ti_mal", "ti_ria", "ti_ure", "ti_mok")]
travel.data.2015.2017[, trip.counts.2015.2017 := sum(to, ti_ban, ti_lub, ti_mal, ti_ria, ti_ure, ti_mok), by = "areaId"]
colnames(travel.data.2015.2017) <- c("areaId", "ad2", "n.2015.2017", "to.2015.2017", "ti_ban.2015.2017", "ti_lub.2015.2017", 
                                     "ti_mal.2015.2017", "ti_ria.2015.2017", "ti_ure.2015.2017", "ti_mok.2015.2017", 
                                     "trip.counts.2015.2017")

# Merge with the 2018 data
travel.data <- merge(travel.data.2015.2017, travel.data.2018, by = "areaId", all = TRUE)

travel.data[is.na(travel.data)] <- 0

# Because the denominators for each data set are different, we have to be careful for how to define them
# For the frequency of leaving model, we'll need to track the total number of people who were surveyed, 
# as well as the total number of people who responded that they left
travel.data[,n := n.2015.2017 + n.2018, by = "areaId"]
# trip.counts.2015.2017 = total number of trips taken, 2015-2017
# trip.counts.2018 = total number of trips taken, 2018, reported in mis.raw
travel.data[,trip.counts := trip.counts.2015.2017 + trip.counts.2018, by = "areaId"]

# For the choice of destination model, we'll need to track the total number of trips with detail reported
# Keep track of denominator separately: n vs. sum over all trip reports from travel.data.2018
# 
# This is where the magic happens:
# trip.counts.2015-2017 = total number of trips taken, with resolved destinations, 2015-2017
# trip.counts.res.2018 = total number of trips taken, with resolved destinations, in 2018, reported in tripsdist/tripsiscom
travel.data[, n.dest.reg := trip.counts.2015.2017 + trip.counts.res.2018]
travel.data[, to := to.2015.2017 + to.2018, by = "areaId"]
travel.data[, ti_ban := ti_ban.2015.2017 + ti_ban.2018, by = "areaId"]
travel.data[, ti_lub := ti_lub.2015.2017 + ti_lub.2018, by = "areaId"]
travel.data[, ti_mal := ti_mal.2015.2017 + ti_mal.2018, by = "areaId"]
travel.data[, ti_mok := ti_mok.2015.2017 + ti_mok.2018, by = "areaId"]
travel.data[, ti_ria := ti_ria.2015.2017 + ti_ria.2018, by = "areaId"]
travel.data[, ti_ure := ti_ure.2015.2017 + ti_ure.2018, by = "areaId"]

# Important note: there are some people in the 2018 data set who report leaving home 
# who traveled both off-island and on-island.  In this case we are counting these folks as only leaving once.
# And we'd need a slightly more complicated model to include both of these behaviors

# Fill in missing values for ad2 ####
# Some corrections, miscategorized locations from the 2015-2017 data set:
pixels.peri <- c(152, 153, 207, 209, 211, 212, 218, 219, 220, 270, 271,
                 329, 330, 386, 387, 443, 445, 447, 448, 502, 503, 504, 
                 505, 506, 507, 560, 564, 571, 573 ,574, 617, 618, 630, 
                 633, 634, 676, 677, 693, 734, 735, 736, 792, 793, 794, 
                 851, 910, 969, 970, 1027, 1028)
travel.data[areaId %in% pixels.peri]$ad2 <- "Peri"
travel.data[areaId == 397]$ad2 <- "Baney"
travel.data[areaId %in% c(218,219,220)]$ad2 <- "Malabo"

# And we now need to fill in all the NA values for ad2
# which are the areas that were populated in 2018 but not earlier
travel.data[areaId %in% c(341, 469)]$ad2 <- "Baney"
pixels.peri.2018 <- c(327, 328, 389, 446, 568, 570, 572, 795, 909, 968, 1261)
travel.data[areaId %in% pixels.peri.2018]$ad2 <- "Peri"
pixels.luba <- c(2084, 2085, 2200, 2204, 2307, 2377)
travel.data[areaId %in% pixels.luba]$ad2 <- "Luba"
pixels.riaba <- c(2753, 2286, 2043, 2403, 2394, 2393, 2337, 2335)
travel.data[areaId %in% pixels.riaba]$ad2 <- "Riaba"
travel.data[areaId == 3500]$ad2 <- "Ureka"

# Save data ####
fwrite(travel.data, here("data/clean/aggregated_2015_2018_travel_data.csv"))
#travel.data <- fread(here("data/clean/aggregated_2015_2018_travel_data.csv"))
# Frequency of travel: fit to probability of leaving trip.counts/n
# Destination: fit multinomial probability to c(to, ti_ban, ti_lub, ti_mal, ti_mok, ti_ria, ti_ure)