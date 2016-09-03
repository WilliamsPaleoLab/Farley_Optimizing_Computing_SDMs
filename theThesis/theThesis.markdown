## A User-Centered Approach to Computing Optimization in Ecological Modeling Workflows
### Scott Sherwin Farley
### Master's Thesis Living Document
### Advisor John W. Williams



# Table of Contents
1.  Introduction
  * Paleoecological data and models are Big, they're in demand, they're super popular these days
  * Models and data are really important to global change prediction
  * Paleodata and it's application to these Questions
  * Cloud computing is an important new tech
  * Prediction is important to support future workflows
  * Hint at framework and optimization of costs/time/accuracy
2.  Research Questions
  * Might need to revise?
    <pre>
    i.	To what degree are the assumptions and logical steps in the framework supported by real world data?
    ii.	Is it possible to make a good prediction of future optimal costs (and thus resource levels) based on a specific user’s goals using a predictive modeling approach? Specifically, can a model with the ability to prescribe cloud-based and client server architectures do statistically better than a null model where all researchers purchase a single desktop computer?
    iii.	Where are the clear breakpoints in user activity, resource level, and cost?
      i.	Are there clear natural breaks in the set of potential users that translate to switches from traditional computing to cloud solutions?
      ii.	What modeling activities would benefit from a shift to cloud computing?
      iii.	Who are the real users that are affected by this breakpoint, if any?
    </pre>
3.  Justify ecological data as big data
  * Use the 4xV framework as developed in blog post
  * Use examples from Neotoma and GBIF
  * Need to supplement with more data
4.  Selected literature review
  * This will need some serious revision from last spring
  * Focus more on the ecological dimensions of why this is important
  * Then connect to computing, machine learning, etc
  * Finally, review algorithms and optimization techniques
  1. Species distribution models
    1. What are they? (brief)
    2. Ecological foundations, niches, use of paleodata to improve accuracy
      * Data availability
    3. Machine learning and species distribution models
      * Models used to be simple (boxcar models)
      * Now they're very complex
      * High variance, low bias
      * Low variance, high bias
      * Look at cited AUC/accuracy metrics
      * No clear winner for all tasks
      * All methods are still widely used
      * Maxent and its popularity
      * Ensemble and parallel methods and their application/accuracy
    4. Prediction and hindcasting using models as a key way to understand the past and future
      * Cite land manager uses here (this is more than just hypotheses for ecological testing)
      * These are real issues that need support (invasive species)
    5.  Meta-analysis/results of targeted reading
      * Other papers commenting on the growth of the field
      * This will flow nicely from the review of what people actually use these models for
  2.  Cloud computing as a technology to support researchers
    1.  Support for machine learning
    2.  Designed for big data and distributed processing
      * We've already clarified that ecological data is Big Data, so this will be easy to reinforce here
    3.  The cloud as a research tool, rather than a market device
      * Not too much on this, but note the economic underpinnings of the computing as a service
      * Cite NSF/NASA/others that require cloud computing for research
  3.  Benchmarking, timing, and why it matters
    1. Systems evaluation and benchmarking
      * Overview of types of benchmarks
      * Application level benchmarks are the best
      * Need for repeated measurements
      * Point of section: stochastic variance in benchmarks
        * Non-linear, complex, hard to model
        * But it's okay
      * Potentially, consequences of using virtual instances --> few, using monitor scripts
    2.  Algorithms Optimization
      1.  What affect's an empirical/theoretical runtime?
        * Introduce my experimental variables
        * Need to read more on the theoretical underpinnings of memory/paging/CPU/etc
        * Briefly touch on theoretical runtime complexity
      2. Other attempts at empirical runtime modeling
        * Need to read more on this
        * We extend this away from just algorithm inputs to hardware inputs too.
      3. Sensitivity analysis vs. optimization analysis
        * Maybe we need to change some terminology here,
        * I think with the alg. opt. literature I can still call it optimization and prediction.
  5.  Problem Formulation
    * Do I need to update this? Probably more or less close to being done
  6.  Specific components of the framework to address in the thesis
    * The framework introduces six components involved in the optimization
    * I just look at one of the central components (time to compute, and address the others tangentially)
    * Demonstrate the proof of concept of the framework, leave the other components to other researchers
  7. Methods
    1.  Data collection
      1. Species distribution modeling inputs
        * GBIF and Neotoma
        * Climate model output
        * Data preparation and cleaning
      2. Simulated data for large memory experiments
        * Do I need to do this? Maybe GBIF would let me do a real species.
        * Simulated data would make more sense from a computing standpoint
        * Real data would make more sense from a user/thesis standpoint
      3. Cost model data
        * Does this go in data? probably
    2.  Computing experiments
      1.  Computing set up
        * Flowchart framework
        * Google cloud description
      2. Serial SDM experiments
        1. Inter-model differences
        2. Taxonomic differences
        3. Parameter sensitivity
        4. Training example sensitivity
        5. Serial SDMs with large memory requirements
        * I think this will be a nice flow of experiment descriptions
      3.  Parallel SDM experiments
        * Need to specifically introduce that these need to be considered separately in my framework, because they respond to differences in cores
        * Might have less accuracy or cost more than methods above,
        * Might have more accuracy than methods above, and can be executed on a single core
        * Just random forests
          * Parallel machine learning methods are a topic of active CS research,
            * This probably needs to go into literature review, or could go into discussion/conclussion
    3. Predictive Modeling Building
      1.  Runtime prediction
        1. Linear model
          * Do I even need to show results of LM?
          * Ref: comments from CI
        2.  GBM
          * Able to capture non-linearities
      2.  Accuracy prediction
        * Build one accuracy model for each SDM class
        * Can we test this from the literature too?
      4. Cost optimization model building
  8. Discussion and Results
    1. Computational runtime prediction accuracy assessment
        * Should formalize this
          * Least squares?
    2.  Accuracy prediction assessment
      * Parallel methods and their accuracy
    3. Cost optimization assessment
      * This will be tricky to assess quantitatively
      * Need to think about this more
      * Qualitatively, we can do this fairly easily
    4. Case study
        * Need to find a good case study
      * Illustrate model results and utility
      * Discuss limitations and uncertainties
      * Discuss confidence in results
    5.  Limitations of current approach
      * How much will the additional components of the framework influence the results?
      * Modeling expertise can do more than predictive modeling
      * Stress uncertainties and lack of predictive skill
      * Scientific realities over modeled optima
        * we should try to find some literature about compromising workflows to meet computational demands.
  9. Conclusion
    1. Reiterate and answer research questions
    2. Next steps to reduce uncertainty remaining in the model
    3. Areas where additional research is needed
      * Parallel machine learning methods
  10. Bibliography 





### Introduction
I propose the development of a framework for predicting the optimal computing resource provisioning strategy for scientific workflows, using species distribution models as a case study.  Advanced computing resources have become ubiquitously available in recent years, and many scientific workflows are based wholly or partially on the application of sophisticated modeling algorithms to reveal structures and insights in scientific data. In my thesis, I will examine Species Distribution Models, a broad class of ecological models that use a learning algorithm to relate climatology and other environmental predictors to species presence.  These models rely on large amounts of environmental data and utilize computationally intensive techniques to characterize a species’ presence over environmental gradients (Franklin 2010, Elith and Leathwick 2009, Svenning et al 2011).  Scientific computing generally involves the application of high performance computing resources to cut down the computational complexity of scientific numerical and simulation models into a reasonable time (Vecchiola et al 2009), and has been used extensively in the geosciences (Yang and Raskin 2009, Yang at al 2010). Species distribution models are not typically grouped with as scientific computing models; however, because of the computational- and data- intensity of these tools, it can be challenging for researchers to determine the optimal amount and configuration of computing resources to apply to the problem.  Provision too few, and the model will crash or fail to run efficiently; provision too many, and the workflow may exceed the allotted time and budget.

With the recent growth of cloud computing, scientists have, in practice, an unlimited supply of configurable computing resources at their disposal, with the only practical barrier to their use being the ability to afford their cost. Incorporating these resources -- processors, memory, network bandwidth, etc -- into a scientific workflow can decrease algorithm execution time significantly.   However, the speedup is not infinite: a lower bound on algorithm execution time is imposed by the amount of parallel computing that can be included in the implementation of the algorithm, known as Amdhal’s Law  (Gustafson 1988).
Cloud computing refers to a broad category of computer architectural design patterns that enable “ubiquitous, convenient, and on-demand network access to a shared pool of configurable computing resources that can be rapidly provisioned and released with minimal management effort” (Mell and Grance 2012, Hassan, 2011, Vaquero et al 2009).  The Cloud has been advertised by many of Silicon Valley’s biggest companies as the next big thing in the technology industry.  It been credited with Obama’s 2012 presidential election win, Netflix’s ability to provide streaming entertainment to millions of consumers, and Amazon’s massive success in online retaining (Mosco 2014). The National Aeronautics and Space Administration (NASA) and the National Science Foundation (NSF) have both officially endorsed the updating of computing systems to include Cloud technology (Mosco 2014).  In the geospatial sciences specifically, the cloud has been posited as the future of geospatial computing and modeling (Yang and Huang 2014).  

With access to cloud-based resources, users now have three different tiers of computing at their disposal. First, a user can employ standard, self-contained, desktop applications, on a single desktop machine, which remains the standard method for most scientific computing, for example, when using the R statistical programming environment.  This paradigm is gradually being replaced with the second tier, consisting of distributed client-server (C/S) systems that consolidate the computing in a centralized server and share the results with distributed clients via the use of the Internet (Granell 2010).  Third, the user can ‘rent’ cloud-based resources, which allows distributed clients and distributed processing on multiple servers – possibly located in geographically distributed datacenters.  With the transition from desktop computer to the cloud comes an increase in available computational power, but also comes an increase in cost and an increase in the complexity of the solution.

Some scientific applications clearly need more computing power than others. ‘Big Data’ workflows often require Cloud architecture, which allows analytical procedures to be done closer to the data, reducing the need for moving massively large datasets (Schnase et al, 2014).  These workflows include peta- to exa-bytes of data and intensive simulations, such as those employed in climate modeling (Schnase et al, 2014), remote sensing and space science (Naqvi et al 2013), and genomics research (Stein 2010).  In the cloud, these applications employ special software and hardware to enable fast, parallel, and distributed processing.  Most scientific workflow applications, however, are unlikely to require the scale and throughput demonstrated by these applications.  However, there is little formal guidance on provisioning the optimal configuration of computing resources for a given workflow.  
Species distribution models are used by ecologists, land managers, and biologists to characterize a species’ biospatial patterns over environmental gradients (Franklin 2010). The specific techniques vary, with both model driven (statistical) and data-driven (machine-learning) approaches seeing widespread use in the literature. While some ecologists debate the relative merits of the approach (e.g., Warren 2012, McInerny and Etienne 2013), these models can be used to predict species distributions under past or future climates, and have seen extensive popularity in a variety of fields, including global change biology, evolutionary biogeography (e.g., Thuiller et al 2008, Aruajo et al 2005), reserve selection (e.g., Guisan et al 2013), and invasive species management (e.g., Ficetola et al 2015). With the fossil record acting as a check on model output, SDMs have been used in paleoecology for ecological hypothesis testing and investigation of model performance under novel and no-analog climate scenarios (Maguire et al 2015, Veloz et al 2012).
Contemporary SDM workflows typically utilize a desktop environment, such as R, to implement complex modeling algorithms that may include regression trees, neural networks, or generalized linear models, among others (Hijmans and Elith, 2016). While working in a desktop environment like R gives scientists access to complex functionality, relies on open source code, and promotes active model development (R Core Development Team, 2016), it creates substantial data management challenges and may not be optimal for applications requiring vast amounts of processing power.  Distributed processing and cloud computing offer the opportunity of additional network-provisioned resources, automatic data management, and enhanced user interfaces (Foster 2005), and their employment may decrease running time of models.  However, it is unclear how much SDMs or other scientific workflows will gain from a decision to switch to these models of computing.

### Ecological Data as Big Data
-

We've all heard the term 'Big Data', though it's often thrown around as a techy buzzword, along with others, like 'The Cloud', without a clear meaning.  In the Williams Lab, we're working with datasets that are sometimes called 'Big Data' in talks by [@iceageecolgist](https://twitter.com/iceageecologist) and others, housed in databases like [Neotoma](http://neotomadb.org), [the Global Biodiversity Information Facility](http://gbif.org), and the [Paleobiology Database](http://paleobiodb.org).  Today, I ask, what characteristics of our data make it 'Big Data'?


### Problem and Scope
> Question: Can ecological biodiversity data fit under the rubric of Big Data? If so, what are the characteristics that make it Big?

First, let's put a limit on the scope of the problem.  Ecology generally has many different subfields, each with their own data and data types.  Some of these may be particularly large, as in the case of ecological modelers, and some may be smaller.  For the sake of argument today, I'll limit the discussion to ecological biodiversity data documenting *occurrences*.   Each occurrence comes with metadata describing what species (typically, but could also be to another taxonomic grouping) was encountered, where it was encountered, and when it was encountered. This type of data is pervasive in the field, and can be used in a host of analyses, including modeling, climate change assessment, and hypotheses testing. Recently, there have been large international campaigns to aggregate these records into large, structured databases that facilitate global biodiversity syntheses.  Three that are commonly encountered are Neotoma (Quaternary), GBIF (modern and instrumental period), and PBDB (deep time).  Since PBDB's ```R``` package was hard to use, I investigate the question today using data from Neotoma and GBIF.


### Definitions of Big Data
There are two often-encountered, decidedly non-technical, designations of Big Data.  The first comes from Wikipedia

> Big data is a term for data sets that are so large or complex that traditional data processing applications are inadequate.
>
> (Wikipedia)

This is commonly seen in the marketing materials surrounding big computation and the cloud, though it's really not a definition at all.  It doesn't say much about what it is, just that 'traditional' means are not capable of processing it, pointing towards distributed computing, cloud computing, and other recent technological advances as its facilitator.  We do get a couple things from this definition though. We know that we're looking at discrete data sets, partitioned, presumably, in a logical manner.  We're looking for data sets that 'traditional' data processing applications are not feasible.  By using these words, 'large' and 'traditional', in particular, we can see that 'Big Data' is in the eye of the beholder, so to speak, and it depends on your tradition of data processing whether a new dataset is Big or not.  Guterman (2009) suggests, "for some organizations, facing hundreds of gigabytes of data for the first time may trigger a need to reconsider data management options. For others, it may take tens or hundreds of terabytes before data size becomes a significant consideration."  From Guterman's perspective, the focus is really on the number of bytes a dataset has, but as we'll see in a minute, there can be other important factors that comprise a data set's Bigness.

The second defintion comes from Yang and Huang's 2013 book Spatial Cloud Computing:
>Big Data refers to the four V's: volume, velocity, veracity, and variety.
>
>(Yang and Huang, 2013)

A varient of this definition can be traced back to an early IBM report on the topic, and can be seen in a variety of cheesy infographics, [like this one](http://www.ibmbigdatahub.com/infographic/four-vs-big-data).  Yang and Huang go on to further describe the meaning of the four V's, noting that "volume refers to the size of the data; velocity indicates that big data are sensitive to time, variety means big data comprise various types of data with complicated relationships, and veracity indicates the trustworthiness of the data" (p 276).  Here we get a bit more structure than the wikipedia definition gives us, and with the two together, we have a pretty good rubric on which to look at biodiversity datasets.

## Evaluation

#### Wikipedia
I argue that the very existence of complex relational databases, like GBIF, Neotoma and PBDB, suggest that biodiversity data do fall under the category of Big Data, as the traditional means of analyzing these data are possible anymore.  Of course, 'complex' in the context of the wikipedia statement typically refers to the preponderance of unstructured data, like videos and photos, and 'large' usually means too big to fit into a computer's memory and/or storage drives.  From this perspective, our data is not complex, rather it's stored in really organized relational tables, and fairly small (the entire Neotoma SQL dump can be downloaded at only 43MB).  

But, if we keep in mind that big data can mean different things to different people, then from our perspective in ecology, our data is Big. Consider the complexity of the relationships between different data records, for example. Figure 1 shows the Neotoma relational table structure, and the complicated web of relationships between each entity.  The data is both spatial and temporal, requiring these attributes, which are known to be messy (see "Veracity"), along with sample data and metadata.  Now, consider keeping track of this for tens of thousands (Neotoma) or hundreds of millions (GBIF) or records, among thousands of independent researchers, and we see why non-traditional techniques like these databases have been developed. Further developments, like APIs and R packages, are even more recent developments to further simplify the tasks of accessing, filtering and working with the datasets. No, ecological biodiversity data does not meet the scale and extent of YouTube, Twitter, or Amazon, but it does require new, custom built tools to store, analyze, and use.

[![Neotoma_ER](/assets/bigData/Neotoma_ER.jpg)](http://www.neotomadb.org/uploads/NeotomaDMD.pdf)
*Figure 1: Neotoma's Relational Table Structure*

#### Volume
Of the four V's, the one that most comes to mind when considering what is, or is not, Big Data is volume: how much data is there?  As the quote from Guterman (2009) suggests, some experts consider this to be the only factor in determining what makes data Big. Our datasets are not on the scale of billions of hours of YouTube videos or hundreds of billions of Tweets, but the scale of biodiversity data has exploded in recent years, bringing it to a place where the volume alone is challenging to manage.

Since the late 1990s, biodiversity databases have quickly and decisively increased the amount of data available to ecologists. Consider Figures 2 and 3, tracking the growth in collections of Neotoma and GBIF through time.  In 1990, only 2 of the records now stored in Neotoma were in digitized collections.  Today, there are over 14,000 datasets.  Each dataset is comprised of spatial and temporal metadata, along with one or more samples with data and associated metadata. The growth rate averages out to about 1.4 datasets every single day for over 26 years.  Considering the time, effort, and money that goes into working up a sediment core (or any of the other data types in Neotoma) this is a really impressive growth rate. For an interesting perspective on ecological Big Data's reliance on blood, sweat, and tears, take a look at this (Blog Post)[https://contemplativemammoth.com/2013/07/10/is-pollen-analysis-dead-paleoecology-in-the-era-of-big-data/] by former Williams Labber Jacquelyn Gill.  

![Neotoma_Growth](/assets/bigData/Neotoma_Growth.png)
*Figure 2: Cumulative number of datasets in Neotoma*

The scale of GBIF is on an entirely different level than Neotoma (perhaps because some of the data gathering challenges faced in getting paleo data don't apply as strongly to modern data collection). Today, GBIF houses digital records of well over 500 million observations, recorded specimens (both fossil and living), and occurrences noted in the scientific literature. GBIF's records are largely comprised of museum collections, which allow their digital collection to date back to before 1900. The facility itself was introduced in 1999 and officially launched in 2001.  Since 2001, the facility's holdings have grown nearly 300%, from about 180 million in 2001 to just shy of 614 million occurrence records today.  Managing 613+ million records and associated metadata, and comping with such a fast growth rate, is, without a doubt, a data management challenge worthy of Big Data classification.  Figure 3 shows the exponential growth in GBIF's holdings since AD 1500, and Figure 4 is an interactive map showing the changes in spatial distribution of their observed data since the late 1800's.

![GBIF_Growth](/assets/bigData/GBIF_Growth.png)
*Figure 4: Exponential growth of occurrence records in GBIF*

<link rel="stylesheet" href="https://npmcdn.com/leaflet@0.7.7/dist/leaflet.css" />
<script src="https://npmcdn.com/leaflet@0.7.7/dist/leaflet.js"></script>
<script   src="https://code.jquery.com/jquery-3.1.0.slim.min.js"   integrity="sha256-cRpWjoSOw5KcyIOaZNo4i6fZ9tKPhYYb6i5T9RSVJG8="   crossorigin="anonymous"></script>
<div id='map' style='height:500px;'>
</div>
1890<input type='range' min='1890' max='2016' step='1' style='width:50%; display:inline-block; vertical-align:middle'
id='gbif_range' />2016
<script src="/assets/gbif_map.js"></script>

*Figure 4: Interactive -- Spatial Distribution of GBIF Holdings Through Time*

#### Variety
The second characteristic of Big Data in the four V's framework is the Variety of the data, and its 'various types with complicated relationships' (Yang and Huang). Biodiversity data is highly diverse with many very complicated relationships and interrelationships.

Neotoma's holdings range from XRF measurements, to geochronologic data, to fossil vertebrates, to modern pollen surface samples.  In total, there are 23 dataset categories in the database, with more being added from time to time. Though it is structured similarly in the database tables, each of these data types comes from a different community of researchers, using different methods and instruments. Figure 5 shows the breakdown of dataset types in the database.

![Neotoma_Record_types](/assets/bigData/Neotoma_types.png)
*Figure 5: Dataset Type Breakdown of Neotoma's Holdings*

GBIF has 9 defined record type categories, including human observation, living specimen, literature review, and machine measurements.  As with the Neotoma dataset types, these are wildly different from each other.  A living specimen is clearly a totally different type of data to work with than something was derived from a literature review. Yet all of these types coexist together in these large biodiversity datasets. Figure 6 shows how GBIF's records are distributed amongst these nine types.

![GBIF](/assets/bigData/gbif_types.png)
*Figure 6: Dataset Type Breakdown of GBIF Holdings*

To further add to the variety and complexity of our data, it is both spatial and temporal in nature, causing complicated interrelationships between data entities. 87.6 % of GBIF's records are georeferenced to a real place in the world. 100% of Neotoma's datasets have spatial information. In these databases, the spatial information is compounded by other fields that describe the location of the observation.  For example, Neotoma has fields describing the site where the fossil was found -- it's altitude, environment, area.  PBDB has extensive metadata for depositional environment, giving additional context to fossil occurrences.  GBIF often notes somewhat colloquial location descriptions in addition to geographic coordinates.   And, of course, there are the relationships between the spatial coordinates themselves -- are these things in the same place? do they overlap?

Managing data with a spatial component is nearly always more challenging than managing data without it. Figure 7 shows how the spatial locations of the datasets contained in Neotoma have changed through time.  Note the expansion in Europe and eastern Asia, and the lack of datasets in Africa.

[![Neotoma_Maps](/assets/bigData/neotoma_spatial_dist.png)](/assets/bigData/neotoma_spatial_dist.png)
*Figure 7: Spatial distribution of additions in Neotoma since 1990*

A final point on variety is that each record, though now cleanly structured and easily accessed as a record in a database, represents the work of an individual researcher.  The controlled vocabularies and organization policies enforced by the databases have helped to efficiently aggregate the data, however, nearly every record was collected, worked up, and published by a unique individual.  Figure 8 shows the number of datasets attributed to each PI in Neotoma.  Yes the names are too small to read.  The point, though, is that while a couple researchers have a very large number of datasets credited to them (John T Andrews has the most with 335), most have many fewer.  The median number of datasets contributed is 2, and the 3rd quartile value is just 7.  Each researcher will use different equipment, in a different way, call things different names, and generally just do things slightly differently -- yielding a highly variable dataset.

[![GBIF](/assets/bigData/Neotoma_PIs.png)](/assets/bigData/Neotoma_PIs.png)
*Figure 8: Neotoma dataset submissions by principle investigator*

#### Veracity
Ecological data has high levels of uncertainty associated with it.  Some can be estimated, like temporal and spatial uncertainty.  Others are less amenable to being quantified, for example inter-researcher identification differences, measurement errors, and data lost in the transition from field to lab to database. See [this paper](http://www.sciencedirect.com/science/article/pii/S0277379116300142#appsec1) for a Paleon project that used expert elicitation to quantify the differences between the dates assigned to European settlement horizon, a process they argue varies between sites, and depends on the "temporal density of pollen samples, time-averaging of sediments, the rapidity of forest clearance and landscape transformation, the pollen representation of dominant trees, which can dampen or amplify the ragweed signal, and expert knowledge of the region and the late-Holocene history of the site." The raw data from the expert elicitation is included as supplementary information in their paper, and can be seen to vary pretty significantly between the four experts.

 Some information will be lost in the process of going from a field site through a lab workflow to being aggregated in the dataset.  Not all process details can be incorporated into database metadata fields, and probably more importantly, contextual details essential to proper interpretation of the data often gets lost on aggregation.

Coincidentally, when I start working on my PhD here at UW, I'll be working to tackle some of these uncertainty issues.

To illustrate the veracity (or lack thereof) of the biodiversity data, let's look at spatial coordinate uncertainty in GBIF and temporal uncertainty of chronological control points in Neotoma. The GBIF database, in addition to recording the geographic coordiantes of an occurrence, also includes a field for uncertainty in spatial location, though this field is optional.  I downloaded 10,000 records of the genus *Picea*, of which over half did not include this field (though all were georeferenced).  This means that even if I am able include and propagate uncertainty in my models (as in Bayesian Hierarchical Models), I would be unable to do so really effectively, because few researchers even report this field. Of the 4,519 records that did report ```coordinateUncertaintyInMeters```, the average uncertainty was 305m (if you exclude zero, which seems reasonable to do). The maximum uncertainty in this dataset was 1,970m.  From this brief, and admittedly flawed, assessment, we can see there are some pretty serious problems with using the coordinates without considering their uncertainty first.  If, for example, you're using 800m gridded climate model output to look at environmental covariates to species presence (which I do), a 300m uncertainty in species location could cause significant deviations due to gridcell mis-assignment, particularly in mountainous regions like the Western U.S.

On the temporal side of things, we can do a similar assessment, this time using the Neotoma data.  Neotoma samples are assigned an age using age controls (like radiocarbon dates or varve counts) or an age model, which interpolates between the age controls. The age model issue is a challenging one, and there's a lot of literature out there about it, as well as software to improve from simple linear models. Every age model is based on a set of age controls, which often have uncertainty associated with them.   Neotoma records an minimum and maximum age for each age control for each dataset.  Out of a sample of 32,341 age controls in the database, only 5,722 reported age uncertainty.  Some record types, like varves, can perhaps be assigned an uncertainty of zero, so we can safely ignore 2,830 more controls, leaving us with 2,892 that report values for minimum and maximum age. The summary statistics for these age controls suggest that the median age model tie point has a temporal uncertainty of 260.0 years. The 25% percentile is an uncertainty of 137.5 years and the 75% 751.2 years.  Using the mean of 260.0 years, I suggest that we can only identify down to &plusmn; 130 years of the actual date.  Considering sediment mixing, laboratory precision, and other processes at work, maybe this isn't that big of a deal, but it definitely is something to be aware of and contributes to biodiversity data's lack of absolute veracity.

#### Velocity
The final piece of the framework is the data's velocity -- how time sensitive is the data.  Data's velocity important because high velocity data must be analyzed as a stream.  Tweets, for example, must be analyzed for trends as they are posted. Knowing the trending topics of two weeks ago might be interesting to me, but the real draw of a Big Data platform like twitter is that I can participate in the trending topics of *right now*.  To do such an analysis, one must use sophisticated sampling techniques and algorithms to detect clusters and trends in real time, for example (this paper)[http://jmlr.csail.mit.edu/proceedings/papers/v17/bifet11a/bifet11a.pdf], which comments on sampling strategies used for trend detection.  

This is the one area where I would suggest that ecological biodiversity data is not Big Data.  Biodiversity analyses, like species distribution models, at least the ones I am familiar with, usually take between a few minutes and a few days to complete and are not especially time sensitive.  The rate of increase in data volume in both Neotoma and GBIF is not fast enough to invalidate the results from previous analyses.  Neotoma gets approximately 1.4 new datasets each day (1990-2016 average).  GBIF gets about 59,000 new occurrences each day (2000-2015 average).  Sure, that's a lot of new datasets, but the likelihood you would actually use the new data in a given analysis is low, and the likelihood that its immediately inclusion into a new model would significantly change your conclusions is even lower.

The velocity of data coming into the databases, particularly into GBIF, is staggering, no doubt about it.  Nonetheless, I don't think it it warrants the use of specialized streaming algorithms for extracting information from the new data points.  I have not seen anyone attempt to do such a thing (though maybe this would be an interesting experiment?).  Moreover, there is little incentive to immediately analyze the data, because there is next to nothing to be gained from modeling biodiversity faster than you can report your results in publications.  

### So, is it?
Velocity notwithstanding, biodiversity occurrence data passes four of five facets of the Big Data, so I conclude that, **yes, it is big data.** It requires specialized databases and software to interact with it, it has large numbers of records, it is extremely diverse, and it has high levels of uncertainty with which to deal.

Looking forward, I suspect Big Data will continue to challenge those involved in synthetic research. Perhaps one of the most challenging aspects is the relatively short period of time in which these data became Big. Figures 9 and 10 show the annual increase in holdings for Neotoma (Fig. 9) and GBIF (Fig 10) through time (top) and the rate of change of annual increase (bottom). While Neotoma's rate of increase as remained relatively steady through time (clear from the near-linear trend in Figure 2), GBIF's rate shows a significant upward trend in the last several years.

[![Neotoma_Delta](/assets/bigData/Neotoma_growth_diff.png)](/assets/bigData/Neotoma_growth_diff.png)

*Figure 9: Neotoma holdings, Annual Change and Rate of Change of Annual Change*

[![GBIF_Delta](/assets/bigData/gif_growth_diff.png)](/assets/bigData/gif_growth_diff.png)

*Figure 10: GBIF holdings, Annual Change and Rate of Change of Annual Change*


### background and Literature Review
#### Modern Computing
Computing in its current form is made possible by the Internet, a massive network of interconnected networks that connects millions of computers worldwide.  The World Wide Web (the Web) is a system of interlinked documents and programs that can be accessed via the Internet (Fu and Sun 2011). The first generation of the Web, released in 1993, was a tool for viewing, not modifying or creating, static content.  Web 2.0 emerged by early 2004, affording users the ability to interact, collaborate, and coordinate with each other, creating, editing, and manipulating dynamic content and programs in addition to static webpages (Yang and Huang 2014).  Web services are programs that run on a web server and expose programming interfaces to other programs on the Web using an established set of Internet standards (Fu and Sun 2011), and are a key component to Web 2.0.  Web services make it possible to modularize and flexibly combine different models and tools to construct tailor-made workflows, potentially underpinning much richer and more interactive systems.  The coupling of web services is facilitated by the development of internet standards that define patterns of orchestration and service connection (Vitolo et al 2014).
	By outsourcing complex tasks to a remote server, web services can be used for a wide variety of modeling activities, including distributed geographic information processing (DGIP), and have become an important and routinely used tool in supporting scientific research workflows (Gouble and De Roure 2008).  DGIP, or geoprocessing, on remote resources often comes in the form of stateless functions that transform a user-specified set of data into a set of outputs.  These functions most often represent primitive actions, for example, a polygon buffering routine, are implemented and packaged in an interoperable and reusable way, facilitating their ability to be easily embedded in many different scientific workflows (Muller 2015).  The linking of geoprocessing services is known as the Geoprocessing Web (Zhao et al 2012) or the Model Web (Guerra and Oliveira 2013), and is a topic of ongoing research (e.g., Granell et al 2013).
One of the most active areas of DGIP research is in its application to cloud-based computing. Cloud computing exposes a configurable set of networked computing resources to an application user in a way that appears unlimited and seamless.  The resources are owned and maintained by a large company, such as Google or Amazon, and are provisioned to the user through the internet for a fee for use. The consumer’s illusion of an infinite pool of resources from which to draw from is made possible through the virtualization of physical computers and the implementation of distributed and parallel processing (Yang and Huang, 2014).    Virtualization is accomplished by a hardware or software element known as a hypervisor that enables multiple virtual systems to be run on a single hardware machine, promoting efficiency by allowing multiple users to use a single machine rather than each purchasing their own machine.  Moreover, this technique provides massive application scalability because it allows users to add or remove one or more virtual machines to their application within only a few minutes. Distributed and parallel file systems, like Google File System and Hadoop (Yang and Huang, 2013, Naqvi et al 2013), are also an important component to cloud computing because they allow processing systems to be composed of many individual hardware nodes and to continue processing even when one of these nodes fails.

#### Estimating Computing Cost
Computing resources are expensive, and their value can usually be tied to their performance.  Nordhaus (2001) argues that two methods exist for characterizing the price of computing performance: (i) measures of the inputs that derive performance or (ii) directly associating cost and performance.  He notes that economic approaches to computing cost estimation have traditionally focused on the first approach, while most computer scientists and those in the computing sector have focused on the performance metrics.  
Examining models of cost per unit performance (for processors) or per byte (for disk drives and memory) shows that more performance is linearly related to the resulting cost . Figure 1 shows the clear link between RAM and cost for several models of memory between 2010 and 2016.

The transition to cloud-based computing solution comes with a transition from a capital cost model to an operational expense model (Hassan 2011).  Desktop and client-server computing paradigms cause users undertake a capital expenditure to purchase desired computing resources before their use.  A bigger capital investment may lead to a higher performance model of computer, however, there is no dynamic scalability, in other words, users are limited to the level of performance they choose at the time of purchase.  In a cloud-based paradigm, on the other hand, users ‘rent’ computing resources.  Rather than a large upfront purchase, they pay monthly based on the resources actually used. Computing resources are scaled up and down with the application need, and can be configured to automatically scale (add or subtract additional resources) as the load on the servers changes.
Estimating the cost of a physical computing solution can be accomplished by assessing the fixed and variable costs of the solution’s components (Alfonso et al 2013).  Here, fixed costs include the purchase of the computing resources themselves, server racks, cooling systems, and other auxiliary components, and administrative costs, while variable costs include the cost of software licenses, operation and maintenance costs, and the cost of supplying the resources with electricity.  

#### System Evaluation and Benchmarking
Analyzing the constantly evolving and multifaceted dimensions of computer performance has posed problems for analysts and scholars since the advent of modern computing (Nordhaus 2001). Because of this, it is difficult to effectively and meaningfully quantify computer Many programs are available to test and measure system performance. These programs, often referred to as benchmarks, are designed to be indicative of system performance under real use.  Many different benchmarking techniques exist, extending from the minutest level of the computational system (e.g., the time taken to execute a single instruction) to high level application suites that test a computers ability to solve high performance scientific simulation problems. High level benchmarks are extremely large and time consuming programs to run, so it often tempting to skip these benchmarks in favor of a smaller and faster one.  These ‘toy’ benchmarks, however, may be too small to accurately characterize the expected system performance of the target application (Lilja 2000).
The execution time of a program depends on the complexity of the algorithm and its input data, the static hardware configuration of the resource, and the dynamic system state (Wu and Datla 2011). Concurrently running programs, operating system tasks, and other factors may affect the execution speed of the benchmark or real program at any point in time.  Various scholars have noted that dynamic changes in state are stochastic, and cause unpredictable, non-linear, and non-additive changes to benchmark results (Kalibera et al 2013, Lilja 2000).  Figure 2 shows the high degree of variance between replicate runs of a short benchmarking routine on my MacBook Air laptop in March 2016.
This stochastic term makes it difficult to characterize the relationship between resources and algorithm execution time. Lilja (2000) suggest that variations are often due to the way in which memory access patterns differ in space and time when small changes are made in the operating system state, timer, or algorithm. However, Lee et al (2007) note that models of computer performance may be capable of capturing high-level trends, though may poorly predict variation in lower level space due to random variation. Kalibera et al (2013) suggest that if the upper bound on performance (e.g., slowest time) for a given algorithm is the metric of importance, benchmarking may be an appropriate tool.  I follow on this and contend that if the stochastic forcing of the system is far below the scale of magnitude we wish to model at we can effectively ignore this term and treat execution time as a deterministic function of system hardware at any point in time.  In the example above, the bulk of the variations fall within 0.06 seconds, less than 10% of the total running time for the benchmarking routine.
Similarly, high-level pieces of code, such as entire applications, should be only minimally affected by the slow-bias incurred while switching between program contexts while timing program execution.  The most intuitive method of measuring run speed is to simply clock the run time with a stopwatch (Lilja 2000).  However, this ‘interval timer’ will actively take up some of the system resources, and thus slow-bias the results of the measurement.  To remedy this, some experts suggest that it is better to measure in terms of CPU time, which denotes the time that the processor(s) actually spent working on the program being measured, ignoring the time it spent on the timer and switching between program contexts.  Because of this variation, which can be up between one and several hundred clock cycles, benchmarking and profiling tools typically report both measurements. However, contemporary personal computers average well over three billion clock cycles per second, resulting in a trivial amount of time being spent on context switching.
The proper measurement and reporting of benchmarks is important and a point of disagreement in computer science.  There is no universal performance metric that answers all performance evaluation questions, and poorly applied performance metrics can be worse than no evaluation at all. Failure to properly characterize the workload, running benchmark tasks in inconsistent environments, and selecting benchmarks that are too simplistic are all errors that can lead to meaningless results (Dongarra et al 2013).  Kalibera et al (2013) note that benchmarking requires repetition and proper experimental design to yield meaningful results, and suggest that analysis of variance and central tendency is much more important than reporting a lower bound in performance when attempting a rigorous benchmarking routine.

#### Estimating Resource Use
There are several techniques for optimizing the number and configuration of computing resources under a given set of constraints.  These techniques are often applied to cloud computing in the context of datacenter optimization, where large warehouses of servers must be dynamically balanced to optimally respond to changing loads. To optimize the datacenter’s efficiency, models are used to predict an algorithm’s execution time given a computing node’s hardware and software state. When a new client request arrives, it must be mapped to available computing resources in an efficient manner.  A scheme that can direct this request to the server that will complete it in the smallest amount of time can improve scientific productivity and the utilization of computing resources (Wu and Datla 2011).
A computing system includes many components  -- everything from CPU components and memory allotment, to display components and networking capabilities.  To effectively model resource utilization, this array of characteristics is typically reduced to a small subset that captures most of the system’s performance.  Sadjadi et al (2008) suggest that the resource components fall into three categories: communication, computation, and storage, and that execution time can usually be estimated using the CPU clock speed and the number of processors available to the application. Wu and Datla (2011) rely on a hardware profile describing processor architecture and speed, memory, buffer, and cache, arguing that RAM can provide information regarding the amount of concurrent work being done on a machine while buffer and cache control the speed of I/O (input & output) operations.  They suggest that these measurements are the most significant in determining performance because they capture most of the variability in estimating both computation time and I/O time.  

Different methods exist for modeling an empirical relationship between hardware and execution.  In most cases, when measuring execution time, we assume that the software portion of the system is held constant, and thus that the number of cycles needed to run the program will remain fixed for a given input size (Wu and Datla 2011), allowing the result to only depend on the provisioned hardware.  Sadjadi et al (2008) model execution time as the product of all individual resource contributions. By estimating individual components with linear terms and expanding, the product function becomes a rather simple linear equation. Wu and Datla (2011) argue that the execution time of a module should be modeled as a multivariate nonlinear system depending on the software complexity and the hardware profile.  Formulating the problem in this way allows the estimation of the effect of a single input parameter, both when acting alone and in combination with other variables. Both of these studies obtained highly accurate estimates of module execution time. I aim to follow on these results and apply similar methods to scientific computing and species distribution models specifically.
Some work has been done to evaluate the differences in algorithm run time due to changes in input parameters.  For example, Hsu et al (2002) evaluate the effectiveness of benchmarking procedures using different data sizes as input to a suite of different computationally intensive algorithms. However, most computing literature that deals with the time complexity of algorithms tends to report results in asymptotic behavior or Big O notation (Knuth 1976).  This is a method of characterizing how the algorithm asymptotically changes with input, but abstracts away the complexities of the hardware profile.  For example, if an algorithm’s time complexity is O(n), the execution time will increase linearly with input, but the exact execution time is not known. Since the purpose of my study is to characterize the differences in hardware configurations, I will have only a passing interest in describing the algorithm’s asymptotic behavior.

#### Species Distribution Modeling:  Fundamental Concepts and Practice
Species Distribution Models quantify the relationship between a species and its environmental range determinants through statistical methods (Svenning et al, 2011). While in a broad sense, this term can include mechanistic or process models, I will strictly focus on the correlative models in this thesis (after Elith and Leathwick 2009). SDMs have been employed in their current form since at least the early 1980s (Vincent and Haworth 1983); however, the utilization of the technique has grown substantially with the rapidly increasing availability of environmental data, species distributional data, and computing resources (Svenning et al 2011, Franklin 2010).  
Species distribution models draw heavily on the niche concept.  Hutchinson (1957) characterized a species’ fundamental niche as an n-dimensional hypervolume that defines the environmental space where the intrinsic population growth rates of the species is positive (Williams and Jackson 2007). The realized niche describes the subset of the environmental space that the species actually occupies at some point in time.  The realized niche is always smaller than the fundamental niche because of the biotic interactions that might limit the species niche at any point in time. The correct interpretation of the species distribution model has been debated in the literature, though most scholars agree that the models approximate the realized niche of a species (Guisan and Zimmerman 2000, Soberon and Peterson 2005, Miller 2010).  Much of the contention surrounding SDM arises from the ambiguities in the formulation of the niche concept, and the differing interpretations of the Hutchinson niche framework (Araujo and Guisan 2006, Araujo and Peterson 2012), rather than the modeling technique itself.  	

The application of SDMs relies on several important assumptions. First, it assumes that the niche of a species remains unchanged through space and time (Pearman et al 2008). This assumption is known as niche conservatism, is a fundamental justification for applying predictions across space and time.  Several authors note that the fossil record supports the hypothesis of niche conservatism in a climate change context (in Thuiller 2008). 	
Second, SDMs assume that species are at equilibrium with their environment.  Environmental equilibrium occurs when a species occurs in all climatically suitable areas whilst being absent from all unsuitable ones (Nogues-Bravo 2009). Given dispersal limitations and biotic interactions between species, this is rarely the case.  For example, many European species are still strongly limited by postglacial migrational lag (Svenning et al 2008).  
Third, SDMs must deal with extrapolation to novel and no-analog climates.  SDMs are strongly limited by the climatic data they are trained on. As with all inductive learning algorithms, these algorithms are fitted with a set of target examples, in this case, species abundance with environmental covariate information.  The goal of learning how the function that defines abundance through multivariate covariate space is made more difficult when we attempt to project the model onto scenarios completely unlike anything in the training set. Williams and Jackson (2007) note the high likelihood of encountering novel and no modern analog climates in the near future. By 2100, large portions of the earth may experience climatic assemblages that do not currently exist, and other assemblages currently present may cease to exist (Williams et al 2007).  Fitting the model with fossil data pooled from past time periods increases the likelihood of capturing the species fundamental niche (Veloz et al 2012), and is a way to limit the number of climates not included in the training example set.  However, the problem of projecting onto novel climates still exists given rapid contemporary climate change.   
	SDMs have many applications in global change biology and paleobiology and are complemented by the fossil record. The paleorecord provides a well-documented set of species and community responses to large, rapid, and/or persistent environmental changes at spatial extents ranging from local to global and at temporal resolutions ranging from subannual to millennial (Maguire et al 2015, Nogues-Bravo 2009).  While niche models that are fitted with paleodata face a number of challenges, they have the potential to harness additional training data and enable hypothesis testing regarding species distributions and their determinants (Svenning et al 2011).   Moreover, fitting species distribution models with paleodata increases the likelihood that the calibration dataset captures the species’ fundamental niche (Veloz et al 2012).
SDMs have been used for a variety of paleogeographic studies including supporting hypotheses for the extinction of Eurasian mega-fauna (Nogues-Bravo et al 2008), identifying glacial refugia in the Pleistocene (Waltari et al 2007, Keppel et al 2011, Fløjgaard et al 2009), and to assess the effect of post-glacial distribution limitations and biodiversity changes (Svenning et al 2011). Recently, SDMs have been combined with genetic, phylogeographic, and other methods for a more complete assessment of biogeographical assessments (e,g., Fritz et al 2013).  A search in Web of Science in March 2016 revealed over 4,000 citations since December of 2013 for the search ((species distribution model*) OR (habitat suitability model*) OR (ecological niche model*)).  
SDM algorithms can be roughly divided into two camps: parametric and non-parametric (Franklin 2010).  Early SDM studies typically focused on the parametric or ‘model-driven’ approaches, which fit parametric statistical models to a dataset, and have continued to see widespread use because of their strong statistical foundations and ability to realistically model ecological relationships (Austin 2002).  Some of the earliest algorithms fit simple multidimensional bounding boxes (‘climate envelope’) around species presences in environmental covariate space (Guisan and Zimmerman 2000).  Other model-driven techniques that continue to see widespread use are generalized linear models (GLM; Vincent and Haworth 1983) and their nonparametric extension, generalized additive models (GAM; Yee and Mitchell 1991).
	The increase in available computing power has spurred the use of  non-parametric or ‘data-driven’ (also referred to as machine learning) SDMs. These models have, in some cases, been shown to significantly outperform their statistical counterparts (Elith et al 2006). Typical data driven models include genetic algorithms (Franklin 2009), classification and regression trees (Elith et al 2006, Miller 2010), artificial neural networks (Hastie et al 2009), and support vector machines.  In 2006, a maximum entropy, ‘MaxEnt’, approach was introduced, an algorithm which has been shown to consistently perform well on small sample sizes and presences only records (Phillips and Dudik 2008).  Because of these characteristics, MaxEnt has become by far the most popular method for SDM. However, recent evaluations of MaxEnt suggest that its performance, especially on small presence-only datasets, may be questionable when compared with other SDM algorithms (Fitzpatrick et al 2013).
No class of model consistently outperforms any other (Veloz et al 2012, Elith et al 2006, Araujo and New 2006), however, scholars have noted variations between model classes (Araujo and Guisan 2006, Elith 2006) as well as between different parameterizations of individual models (Thuiller 2008, Araujo and New 2006, Veloz et al 2006). Therefore, it is important for workflows to include several different model classes and parameterizations (Araujo and Guisan 2006), and/or employ ensemble-forecasting techniques (Araujo and New 2006, Miller 2010).  The choice of model class is dependent on a number of factors.  Model users should consider the region in which they are working (Elith et al 2006, Hernandez and Graham 2006), the number of records they have to work with (Wisz et al 2008), the type of record (presence/absence or presence-only) (Franklin 2009), the ecological implications of the model output (Austin 2002, Austin 2007), and the user’s competency with the chosen model.  Additionally, Franklin (2010) points out the tradeoff between model precision and generality (data-driven vs. model driven approaches), response function estimates, multicolinearity and autocorrelation between model predictors.
Once fitted and projected, SDM results can be evaluated in a number of ways that describe the characteristic performance of the routine.  However, reducing model results into a single statistic can hide important insights about model performance (Franklin 2010, Lobo et al. 2008).  By doing so, the spatial pattern of model error is lost.  Furthermore, most discrimination metrics require that continuous estimates of probability of species presence be transformed into binary estimates of presence and absence, so are thus sensitive to the choice of threshold, and can mask nuances in the predicted response (Lobo et al 2008, Austin 2002, Miller 2010).  
A common metric for model comparison is the area under the receiver operator curve (AUC).  The receiver operator curve (ROC) plots the sensitivity (correctly classified presences) against the fraction of commission errors (falsely predicted presences).  Calculating the area underneath this curve provides a measure of success across all possible ranges of thresholds, equivalent to a non-parametric Wilcoxon test (Hanley and McNeil 1982), where the rank of all possible pairs for presence and absence probabilities is compared (Lobo et al 2008).  Other important statistics for model evaluation include the Cohen’s kappa statistic, percent correctly classified, and the true skill statistic, all of which are based on the confusion matrix that compares observed discrete cases to predicted discrete cases (Miller 2010).   In response to critiques on these methods, other evaluation methods, such as the true skill statistic, have been shown to perform well in an ecological setting (Miller 2010). The choice of model evaluation techniques should reflect the modeling study’s objectives (Miller 2010, Araujo and Guisan 2006).

### Problem Formulation
I present a framework for linking the ideas of model user goals with modeling execution time and computing resources that leads into my research questions.  My thesis research will attempt to lend support to this theoretical framework with empirical data.
1.  First, let us consider a single computer or pool of computing resources, H.  At any time t, the effective processing power of H is related to both static and dynamic configuration of its hardware and software (Wu and Datla 2001). We can characterize the available resources as:
H(t)=H_static+H_dynamic+ ζ
Where Hstatic represents the static capabilities of the machine that do not change with time, and Hdynamic represent the capabilities of the machine that do. We know that execution times can vary non-deterministically with hardware due to the random effects of small changes in system state, so we add ζ as a stochastic component that accounts for the random variance in H(t) at any time t. The random term may cause some amount of unexplained variance in a predictive model.
Through experimentation, we can estimate the computation time, Tcompute of a given algorithm with a given set of resources on a given H(t), as well as the magnitude and distribution of ζ.

	2.  Assume that the cost of a given set of computing resources is a stepwise function of H, the provisioned computing resources.
C_compute=f(H)
In an academic environment, many of the terms in Alfonso et al (2013) computing cost model are not applicable.  For example, most research laboratories do not pay directly for electricity, already have an existing physical space, and have departmental or university IT staff to assist with maintenance and operation.  Furthermore, many software packages are provisioned for free to academic entities, and many other widely used packages, such as R, are free and open source software. Thus, in the university setting, we can simplify the cost model for non-cloud based computing to just depend on the purchase price of the computing components.
Figure 3 shows an idealized set of computing cost curves.

3.  Now let us consider the user of the computer application.  Every user of an application has a particular set of goals for using that interface in the first place (Norman 1984).  Using techniques from Scenario-Based Design (Carroll 1999, Rosson 2002), we can come up with a finite number of use cases for a given application that fall within the bounds of existing or expected use.  For example purposes let us define a scenario typical of a species distribution model user:

Jessica Smith is a land manager at a Yellowstone National Park, interested in understanding how her park will be affected by Mountain Pine Beetle infestations under different anthropogenic climate change scenarios.  Ms. Smith primarily wishes to characterize how the beetle range might change under the three most likely IPCC emissions pathways. She does not care about the differences between algorithms or uncertainties that may arise in the modeling process, as long as he can present his results to her colleagues.

From this brief scenario, we can formalize Ms. Smith’s goals with the SDM application.  He wishes to model one species (Dendroctonus ponderosae), in one area of known size (Yellowstone National Park, ~3,500 mi2), under three different climate scenarios.  She only requires the use of a single SDM, that his accuracy requirements are fairly low, and his budget may be limited.
Using brief user-based scenarios like this, we can begin to formulate the concept of a User, U. Let U be a vector of characteristics that formalizes the scenario’s goals. The components of U are: a vector of experiments (discussed below), as well as user traits such as experience, interface used, motivation, skill, accuracy required, etc.  The experiment vector holds a list of experiments that specify the number and character of the modeling work the user wants to accomplish. Each element in Experiments can be expressed as a vector of model characteristics that contain enough information to specify the runtime behavior of a single model at a single time period, including spatial resolution, number of input training examples, number of input predictor/covariate layers, number of time periods to project onto, and type and number of algorithms to utilize.
4.  Let us now turn to estimating the total time required to run a modeling experiment. The time to actually compute a given algorithm with some set of input data, TCompute, is a function of H(t); however, several other terms can contribute to the total time spent by a user.  We can express the total time taken by an experiment as
T_Model= T_Input+ T_Prep+ T_Compute+ T_Output+ T_(Interp.)
Where TInput represents the portion of time that is spent by the user gathering the resources needed to model.  In a species distribution modeling context, this term represents the time needed to find and download occurrence points, time needed to find and download predictor variables, and time needed to setup and configure the algorithms (i.e., download and install R packages).  We will consider TInput a function of the computing resources available to the user (how fast can the data be downloaded?), and the experiment (what is the data and how big is it?). TPrep is the time required by the modeler to prepare the data for entry into the algorithm.  In our case, this time might be spent deleting erroneous points, projecting data into new spatial references, or converting between data formats.  We will characterize TPrep as a function of the experiment (what is the data?), the user (how skilled are they?), and the interface (how easily can the tasks be completed?). TCompute is the time needed by the computer to run an algorithm on a given set of data and will be considered a function of H(t) (how fast is the computer?) and the experiment (how much work does the computer have to do?).  TOutput is the time it takes to return the output from the computation to the user. While this time is often minimal, an experiment with a large data output that is run on remote resources might need a non-trivial amount of time to download to a user’s client over a network.  Let us only consider TOutput in terms of H(t).  Finally, TInterp. is a function of the user and the interface that represents the time required by the user to evaluate the model output and determine whether his/her goals were met. Thus, TModel can be expressed as a function that depends on the user, the experiment, and H(t).

5.  Now that we have characterized the time it takes to run a single experiment, it follows that the time to model all experiments in a user’s goal is the sum of all modeling experiments, so a user’s time-to-goal is expressed as:
MATH

6.  Combining equations from (2) and (5), we can estimate the total ‘cost’ of a modeling workflow as the sum of the total time spent modeling and the cost of the provisioned computing resources.  We can represent our cost function as a multidimensional function that takes into account both the time spent modeling and the cost of the provisioned resources:
MATH
7.  Now let us take a defined, single, discrete user (like Ms. Smith introduced earlier) and call this user U*.  By holding U constant at U*, we can now obtain a unique cost function for this individual’s modeling activities that is now only a function of H(t). C is defined for all real computing solutions greater than 0 however, we can define the optimal solution, C*, for provisioning resources to U*’s activities as the multidimensional minimum
MATH

which suggests an cost optimum at C* and an associated resource optimum at some profile Y*.  The minimization routine should be such that:
	MATH

After building up this theoretical framework, there are three logical extensions that will be examined in more detail in this thesis:
i.	To what degree are the assumptions and logical steps in the framework supported by real world data?
ii.	Is it possible to make a good prediction of future optimal costs (and thus resource levels) based on a specific user’s goals using a predictive modeling approach? Specifically, can a model with the ability to prescribe cloud-based and client server architectures do statistically better than a null model where all researchers purchase a single desktop computer?
iii.	Where are the clear breakpoints in user activity, resource level, and cost?
i.	Are there clear natural breaks in the set of potential users that translate to switches from traditional computing to cloud solutions?
ii.	What modeling activities would benefit from a shift to cloud computing?
iii.	Who are the real users that are affected by this breakpoint, if any?

This study will focus heavily on the case study of species distribution modeling, and will work specifically on optimizing the resources for these ecological problems.  However, some portions of this framework might be extended to other situations.

### Methods
1.	Characterizing Users: I will systematically review the species distribution modeling literature to understand the range of use cases for species distribution models.  To systematically review, I will download the last 4,000 citations in the Web of Science returned with the keyword search “(Species Distribution Model*) OR (Ecological Niche Model*) OR (Habitat Suitability Model*). I will then use a random number generator to randomly sample these citations to yield a list of 150 citations.  I will then review these papers looking for key criteria that explain how the authors will be using species distribution models. I will collect the following fields: year, number of model classes, number of predictor variables, number of occurrence points, number of evaluation metrics, number of species, spatial extent and resolution of study, number of climate models, number of different time periods, model classes used, and evaluation metrics used.  This meta-analysis will be used to evaluate clusters and patterns that may be apparent in the data.  I will use multi-dimensional cluster analysis (k-means) to determine clusters of similar users.  

2.	Cost Model: I will develop a theoretical cost model for cost of computing time. I will base this model by looking at a sampling of computer prices from well-known vendors, including Dell, Apple, and HP.  I will evaluate the cloud subspace of this model by reviewing the hourly compute rates for different virtual instances on Amazon, Rackspace, and Google, all of which provide IaaS capabilities (Yang and Huang 2014).  After this step, I will be able to compute the hourly cost of computation on any given computer.  This process essentially accounts for the upfront costs of purchasing physical machines versus renting cloud and virtual machines.

Experimental Variables
----------------------

### CPU Cores

Virtual CPU cores (vCPU) are included as an experimental variable,
because their addition to a problem is the only way to to directly
increase the number of instructions being executed by the machine. With
a single processor machine, instructions must be sequentially executed.
If there are multiple processes running on a machine at one time, the
instructions must be interleaved to give the illusion of simultaneous
execution. If one or more cores are added, the workload can be split
across these processors to execute the instructions in parallel. If a
modeling algorithm is a serial algorithm (most SDMs are), adding
multiple cores can improve its speed by offloading system processes and
other work to other processors, leaving one processor for model
execution. If the model is designed for parallel execution, adding cores
can speed up the execution of the algorithm proportionally to the
percentage of the program that can execute in parallel (Amdhal’s Law).
Most programs require at least a small amount of serial code (to
synchronize results or initialize runs), so infinite speedup is not
possible. The algorithm I’m using (boosted regression trees in the gbm R
package) is designed with a small portion of parallel code, so should
demonstrate at least a small speedup with the addition of multiple
processor cores.

### Memory

Adding virtual memory (RAM) to a process can increase its execution time
by reducing the number of times the computer must retrieve data from the
physical storage device (e.g., the hard disk). Operating on data from
the hard disk, especially a traditional mechanical one) is orders of
magnitude slower than operating on instructions that are already stored
in the computer’s main memory. If the size of the data to be executed on
exceeds the size of the RAM, the computer will automatically chunk it
up, and go back and forth between the hard drive and main memory. By
increasing the size of the memory, we reduce the need to go to the hard
disk, thus increasing execution time.

### Training Examples

All of the competitive species distribution models (generalized linear
models, regression trees, adaptive splines, etc) are instances of
supervised learning. Supervised learning methods required a set of
tagged training examples that show the ’correct’ answer, along with that
answer’s input conditions. The goal of the learning method is then to
learn the function *h(x)* that approximates the mapping between input
conditions to answer. More tagged examples gives the learner more data
with which to work, and, in theory, should demonstrate higher accuracy.
However, giving the learner more data means that it will need to fit a
more complicated response surface. I hypothesize that giving the
modeling algorithm more training examples will increase the time it
takes to learn *h(x)*.

### Spatial Resolution

The fitting of the models is essentially non-spatial: the environmental
covariates are pre-extracted from the predictor layers, processed, and
fed to the model. Once the model is fit, however, the response *h(x)* is
projected onto the RPC8.5 scenario for AD2100. A low spatial resolution
prediction grid will have only a relatively small number of grid cells
to project onto. As spatial resolution increases, the number of cells on
which to project increases exponentially. Thus, while the fitting time
of the model is unlikely to be affected by the spatial resolution of the
response, the time it takes to produce a gridded output will likely
increase significantly at higher resolutions.

Experimental Design
-------------------

In an ideal world, I would run carefully controlled experiments in a
full factorial design for each of these experimental variables, with a
suitable number of replicates per cell for robust inference. However,
there are a couple reasons this is not possible in my case.

1.  **Cost** It is prohibitively expensive to test every combination of
    the variables, particularly with replicates.

2.  **Time** I am also limited in the time I have to run these
    experiments, and do not have the thousands of hours needed to run
    all of these simulations.

3.  **Platform** Cloud platform providers do not allow unconstrained
    creation of arbitrary machine types.

![Distribution of experiments across computing types. Experiments in
green have been completed to-date.<span
data-label="fig:conf_status"></span>](config_status.png){width="60.00000%"}

Because I can’t run all of the experiments, I came up with a compromise
scheme that attempts to balance capturing the within-variable variance
(more replicates) with the interactions between the variables (more
cells) . I do this by running one main series of experiments with a
selected subset of algorithm inputs (training examples and spatial
resolution) on a wide variety of computer types (vCPU and memory), and
then a couple of sensitivity analyses that capture the response of the
algorithm to a change in a particular input.

### Main Series

The goal of the main series is to capture the interactions within
variables, and to capture the contribution of running the algorithms on
increasingly more powerful machine types. Because execution time can
demonstrate non-linear and/or non-additive responses when run on
alternate hardware, it’s important to test as many combinations of the
two computing variables as possible. On each computer type, I have a
standard set of 160 experiments to run (4 spatial resolutions x 4
training example sets x 10 replicates). All of these experiments are
done on the *Picea* pooled niche data set. Figure \[fig:conf\_status\]
shows the computing instances that I use in the main series.

### Taxa Sensitivity

  vCPU     Memory
  ------ --------
  1             3
  2             8
  3            15
  8            30
  16           60
  32          208

  : Computing configurations in the taxa sensitivity experiments.<span
  data-label="tab:tSensitivity"></span>

There is not a clear reason why the execution times should vary between
different taxa, because the model will fit with the same number of
training examples and project onto the same spatial grid. But, to
evaluate whether differences among taxa do occur, and if so, to the
magnitude of the variation, I have a series of experiments that test on
four different taxa. These taxa are *Picea*, *Tsuga*, *Quercus*, and
*Betula*. The tSensitivty set is run on 6 instance types, as shown in
Table \[tab:tSensitivity\].

### Training Example Sensitivity

![\[fig:tSensitivty\]Number of training examples included in the
training example sensitivity set of
experiments.](tSensitivity.png){width="50.00000%"}

To test the affect of adding training examples on the fitting time of
the algorithm, I have a set of measurements to evaluate this effect on a
single computing type for more examples than I have in the main series
of experiments. Different numbers of training examples between 100 and
30,000 are examined, as shown in Figure \[fig:tSensitivty\].

### Spatial Resolution Sensitivity

To evaluate the hypothesis of an exponential increase in model
projection time with a proportional decrease in spatial resolution of
the output grid, I have planned a sensitivity test for spatial
resolution. Fitting a standard model, I will evaluate the projection
time at between 0.1 and 1 degrees resolution by 0.1 degree step size.

Platform
--------

I am using the Google cloud platform (a.k.a Google Compute Engine) to
complete all of my experiments. On this platform, Google rents out
isolated portions (e.g., instances or nodes) of its massive computing
infrastructure to consumers. The consumers, like me, pay per minute for
the resources that they use. These nodes can be very basic (1 vCPU and
0.6 GB RAM) or exceptionally powerful (32 vCPU and 208GB RAM), or nearly
anywhere in between. Along with the platform, Google has developed a set
of APIs for automated control of the virtual computing instances, as
well as a GUI console for interactive control.

The main reason for this choice is the ability to create ’custom’
instance types. Other notable cloud providers (e.g., Amazon Web
Services) provide a large number of predefined instance types, some even
more powerful than Google’s top-end, but do not allow you to create an
instance with an arbitrary number of vCPU cores and memory. Google
allows you to do this, which fits well into my experimental framework.

![A flowchart describing the way in which virtual infrastructure is
managed to run SDM simulations.<span
data-label="fig:flowchart"></span>](file-page1.jpg){width="110.00000%"}

My setup draws on a bit on the design of larger systems like Hadoop,
which create frameworks for massively large and distributed
fault-tolerant systems. In short, I have one Master Node that hosts a
database and a control script, and a pool of compute nodes that are
fault-tolerant and designed only for computing. The compute nodes don?t
have to know anything about the progress of the entire project and can
handle being shut down mid-run, and the control node doesn?t have to
know anything about the simulations being computed. At any one time I
will have one or many servers that will actually be doing the job of
computing the species distribution models and assessing their time and
accuracy (compute nodes). At the same time, I will have one server that
hosts the database and the API, starts and stops the computing
instances, and cleans up the workspace when necessary (Master Node).
This approach allows me to use Google’s preemptible instances, which
cost much less, but have the potential to be dropped due to system
demand at any time. Figure \[fig:flowchart\] shows a conceptual diagram
of the platform logic.

### Configuring and building virtual instances

The steps to building and configuring the pool of computing nodes takes
follows this general process:

1.  The MasterNode.py script uses the (daemonized \[always running\])
    node.js web backend to query the database to ask ’What experiments
    have not yet been marked as DONE?’. The computing script could also
    mark experiments as “LEGACY”, “INTERRUPTED”, or “ERROR” depending on
    the conditions at runtime. If they have not yet been computed, they
    are marked in the database as “NOT STARTED”. So MasterNode asks for
    everything that?s not “DONE”, and forces a re-compute if a
    simulation errored or was cut short.

2.  The central database, via the API, responds with a JSON object that
    contains the number of cores and memory needed for the next
    experiment (but not the other experimental parameters like number of
    training examples or spatial resolution).

3.  MasterNode parses the JSON and then uses the gcloud tools to create
    a pool of computers that have the memory and number of cores
    specified by the database response. This pool of virtual instances
    is automatically created with a startup script that installs the
    necessary software and files to run the computing experiments.

### Running the simulations and reporting the results

Now that I have the pool of virtual instances at my disposal, I can use
them to run the SDM simulations, time their execution, and report back
to the central database. There are typically between 160 and 400
simulations to be done for every computing configuration, so on each
node is an inner loop that looks like this:

1.  Startup script installs git, mysql, and R. Git clones the most
    recent version of the project repository which has all of the files
    needed for the computation. R starts execution of the timeSDM.R
    script which controls the flow of execution for this node.

2.  RScript queries the central database to ask ’I am a compute of x
    cores and y GB memory, what experiments can I do?’.

3.  The database responds with a single JSON row that contains all of
    the necessary parameters to actually run the SDM simulation (spatial
    resolution, taxon, number of training examples, etc).

4.  RSCript parses the database response and loads the correct set of
    variables, then runs the SDM model.

5.  RScript reports results back to the database and marks that
    experiment as “DONE”.

6.  Repeat until no experiments that are not “DONE” remain to be
    completed by a computer of this number cores and amount of memory.

If an instance gets shut down due to preemption (or my incompetence) a
shutdown script will be fired. This script records in the database that
the experiment was cut off (INTERRUPTED) at some point before successful
completion, and that it should be completed again in the future.

### Managing virtual infrastructure

Because Google charges you by the minute as you use their servers, and
because I have to do a lot of different experiments and don?t have that
much time do them, it is ideal to automatically tear down the servers
and start a new pool as soon as one computing configuration has
finished. So, while the computing nodes are doing their computing thing,
the MasterNode repeatedly polls the central database to determine the
current position within the experiment grid.

1.  MasterNode uses the API to ask the database ’What percentage of the
    experiments in this group have been completed?’

2.  The database responds with a percentage (“DONE” / total).

3.  If the percentage is 100 (all experiments have been completed within
    the current configuration setup):

    1.  MasterNode will use gcloud to delete the individual server
        instances, the instance group pool the they are part of, and the
        template used to create the instances. After this, only the
        Master Compute Node server with the database on it still remains
        in my pool of Google resources.

    2.  Repeat. Configure and build a new pool of instances for the next
        memory/cores combination.

4.  Otherwise, continue polling.

Modeling Protocol
------------------

### Data Origin & Preparation

The taxon occurrence data is from the Neotoma Paleoecological Database.
All records for the given taxon were downloaded from Neotoma, using the
API. A python script was used to identify all of the sites with that
taxon. For each site, the entire dataset was then downloaded, and the
values for the taxon extracted. The age, latitude, longitude, site
identification information, and the relative abundance was stored for
each Neotoma occurrence as a comma separated value file.

For each occurrence record from Neotoma for my chosen species, I
extracted the bioclimatic variables at the given latitude, longitude,
and years BP. The extraction was done using a python script, and the
results were then stored as CSV files.

The paleo climatic predictor layers are downscaled North American CCSM 3
model simulations (Lorenz et al 2016). The model data was obtained in
netCDF format, and manipulated in python. Bioclimatic variables were
calculated from these native layers using the O’Donnell (2012)
methodology, using the biovars function from the dismo R code package.
These layers have a native resolution of 0.5 degrees.

The future climatic layers, describing AD2100, for use as output
predictors, were obtained from the CMIP project, HadCM3 climate model.
These layers model describe the model under the UN IPCC RCP 8.5 forcing
scenario. The layers were used to calculate bioclimatic variables, and
were then resampled to various resolutions to facilitate their use as
output layers in different experiments.

### Modeling Methodology

I have worked with three SDM algorithms that have shown competitive
accuracy results in the literature: (1) multivariate adaptive regression
splines (MARS), (2) gradient boosted regression trees (GBM-BRT), and (3)
generalized additive models. All of the models were fit using the R
statistical environment with standard packages for these learning
methods. The input data is communicated by the central database to the
computing node, and then passed to the gbm function. The learning
parameters of the function are held constant over all experiments. There
is no database I/O inside of the function, so results should not be
slow-biased by network connection or context switching.

The experiment parameters are first communicated from the database to
the computing machine. The computing node parses the database’s response
and starts a new experiment session. The correct set of training
examples is loaded from disk. It is then randomly partitioned into a
testing set of $\mathcal{N}$ random training examples and  10,000 (20%
of total) testing examples that are excluded from the training set.
Examples are converted to binary presence absence values using the
Nieto-Lugilde et al (2015) method for determining local presence from
fossil pollen records. The training set is sent to the learning function
where an SDM model is fit. All models are fit on the five least
correlated bioclimatic variables (bio2, bio7, bio8, bio15, bio19). The
model is then projected onto the future predictor set. The gridded
output is then used to evaluate the accuracy of the model, using the
testing set. Results of timing the total time, model fitting time,
prediction time, and accuracy calculation time, as well as various
measures of accuracy are then communicated back to the central database.

Status
======

![\[fig:experimentByCategory\]Percentage of experimental variables that
have been ’seen’ by the SDM
simulations.](CompletionByType.png){width="50.00000%"}

![\[fig:completionByCategory\]Percentage of experiment statuses
currently in the database.
](experimentByCategory.png){width="60.00000%"}

As of July 1, I’ve run 20,583 of the experiments as described above,
which equates to approximately 20% of the total. Some of the models have
been returning NULL, particularly at lower numbers of training examples.
I suspect that the model does not have sufficient information to fit the
model with such few data points, and this has resulted in a sizable
number of errors in the results set. Figure \[fig:completionByCategory\]
shows the relative distribution of successful runs, errors, and runs yet
to be started.

While my model has ’seen’ relatively few of the more powerful computing
configurations, it has been exposed to all of the training examples and
spatial resolutions in my protocol, so I can be fairly sure of the
affect of altering these variables. Figure \[fig:experimentByCategory\]
shows the percentage of discrete values completed for each experimental
variable. I am fairly certain of the effect of spatial resolution and
number of training examples on the execution time of the model. While
not quite as complete, I have seen a large number of different computer
cores and a decent amount of RAM configurations as well. The completion
portion of the computing variables are also clearly shown in Figure
\[fig:conf\_status\].

I contend that, while a relatively small percentage of the total
experiments have been completed, a sufficient number of runs have been
done and a representative set of experimental variables have been seen
to make claims about the validity of the these preliminary results.

Results
=======

Exploratory Analysis of GBM-BRT Data
------------------------------------

![Relationships between individual experimental variables and total time
in seconds.<span
data-label="fig:all_vars"></span>](all_vars.png){width="75.00000%"}

Exploring the data leads to the surprising initial conclusion that
neither the number of vCPU cores nor the amount of memory a computer
significantly and consistently affects the speed performance of the
model. Over all experiments in the main series, the r^2^ correlation
coefficients are 0.001 and 0.042 for vCPU and memory, respectively.
While these predictors do very little to influence the response, the
number of training examples used to fit the model appears to be a very
important factor in the total running time of the model (r^2^ = 0.85).
Spatial resolution shows a moderate negative correlation with time (r^2^
= -0.26). Figure \[fig:all\_vars\] shows the relationships between the
experimental variables and model execution time, clearly showing the
strong influence of the algorithm inputs, and lack of influence of the
hardware variables.

![Effect on time of adding additional vCPU cores. Series are memory
amounts. Evaluated by taking the median time of each combination of
cores and memory.<span
data-label="fig:cores_vs_memory"></span>](Cores_and_memory.png){width="65.00000%"}

![Effect on time of adding additional memory. Series are number of vCPU
cores. Evaluated by taking the median time of each combination of cores
and memory.<span
data-label="fig:memory_vs_cores"></span>](Cores_by_memory.png){width="65.00000%"}

Figure \[fig:memory\_vs\_cores\] shows demonstrates a confounding upward
trend in execution time as memory increases, suggesting that adding more
memory to the problem can actually slow down the execution. Perhaps this
is due to the increased overhead of maintaining a larger main memory.
Figure \[fig:cores\_vs\_memory\] shows the lack of response in either
direction stimulated by adding additional cores.

Predicting Execution Time
-------------------------

### Multiple Regression

Using a linear model with four predictors, I developed a simple
predictive model for execution time. This assessment shows that the
model does a decent job at predicting an independent testing set. The
model is an additive combination of all four of the variables and takes
the form:

$$totalTime = 1.901 - 1.885Core +  2.012GBMemory + 1.025NTE - 3.870SR$$

Where $totalTime$ is the full model execution time, in seconds, $Core$
is the number of vCPU cores, $GBMemory$ is the number of gigabytes of
main memory, $NTE$ is the nmber of training examples used to fit the
model and $SR$ is the spatial resolution of the output grid.

![\[fig:modelStats\]Linear model residual structure and Q-Q
plot.](residuals_and_QQ.png){width="75.00000%"}

  Predictor           FStatistic   pvalue   Significant
  ------------------- ------------ -------- -------------
  cores               0.1075       0.7431   F
  GBMemory            100.1390     0        T
  trainingExamples    21701.4452   0        T
  spatialResolution   2326.5653    0        T

  : \[tab:anova\]Analysis of variance for the full linear model.

The model shows a multiple r^2^ of 0.7426, demonstrating that much of
the variance in the response is captured by the input predictor
variables. As Figure \[fig:modelStats\] shows, the model residuals show
significant structure, and deviate far from a normal distribution. To
further evaluate the contribution of each predictor, I used an anova on
the linear model $\mathcal{M}$. The ANOVA table (Table \[tab:anova\])
shows that all of the variables are statistically very significant
predictors, with the exception of vCPU. Surprisingly, memory is shown to
be a significant predictor, even though it does not appear to be when
evaluating it on its own. As expected, by far the strongest predictor is
the number of training examples.

I evaluated the predictive skill and accuracy of the full linear model
using an independent testing set of 1,000 records. I predicted the model
using the ’predict’ function in R. I then compared the predicted values
from the model the the observed values from the database. Figure
\[fig:full\_hist\] shows a histogram of the model error and how the two
datasets line up (r^2^ = 0.87). The linear model has a root mean square
error of 23.73 seconds and has a mean overprediction of 1.04 seconds.

![\[fig:full\_hist\]Histogram of full linear model
error.](full_hist.png "fig:"){width="35.00000%"}
![\[fig:full\_hist\]Histogram of full linear model
error.](full_model_accuracy.png "fig:"){width="35.00000%"}

### Boosted Regression Trees

I also used boosted regression trees to predict the execution time of
boosted regression trees (inception?). The GBM tree model performed
slightly better than the simple linear model. The regression tree model
shows a RMS error of 19.45 ( 3 less than linear regression), with around
0.88 seconds mean overprediction (.2 seconds less than linear model).
Figure \[fig:gbm\_hist\] shows the gbm model prediction errors and the
histogram distribution of these errors. Again, there appears to be clear
structure in the residuals, though the residuals are slightly more
stratified that in the linear model, probably due to the discrete
structure of the tree-based model.

![\[fig:gbm\_hist\] Evalutation of GBM model
error.](gbm_hist.png "fig:"){width="35.00000%"} ![\[fig:gbm\_hist\]
Evalutation of GBM model error.](GBM_acc.png "fig:"){width="35.00000%"}

More training examples, more accuracy?
--------------------------------------

![Relationship between number of training examples and the time needed
to fit the species distribution model simulation.<span
data-label="fig:nte_time"></span>](nte_time.png){width="50.00000%"}

![(1) Training examples vs. model AUC, (2) Boosted regression model of
testing AUC score as a function of number of training examples..<span
data-label="fig:acc_model"></span>](training_vs_ac_abline.png "fig:"){width="35.00000%"}
![(1) Training examples vs. model AUC, (2) Boosted regression model of
testing AUC score as a function of number of training examples..<span
data-label="fig:acc_model"></span>](nte_accuracy_gbm.png "fig:"){width="35.00000%"}

Perhaps the only clear relationship I’ve uncovered so far is that
fitting time increases exponentially with the addition of more training
examples (Figure \[fig:nte\_time\]), but do the additional training
examples yield better predictions? Plotting the testing set AUC
statistic against the number of training examples shows that predictive
skill increases significantly between 100 to 10,000 input points, but
then levels off. From this data, it is clear that to obtain optimal
results, at least 10,000 input training examples should be used. Figure
\[fig:acc\_model\] shows a non-linear regression tree model to predict
the AUC statistic from number of training examples. A simple linear
regression cannot capture the log-shaped curve that the data in Figure
\[fig:acc\_model\] shows. The stair stepping in the GBM model is due to
the fact that I tested at discrete intervals, and not continuously
between 0 and 30,000 examples.

 Other SDMs
-----------

The other two SDMs showed similar results to the GBM-BRT method. The
predictive accuracy of the execution time models were on par with the
GBM-BRT models discussed above, however, nearly all of the predictive
skill comes from the number of training examples rather than the
computing configuration.

![Predictive skill of the predictive models on all SDM types.<span
data-label="fig:all_models"></span>](CI_plot-I.png){width="85.00000%"}

Figure \[fig:all\_models\] shows the results of the predictive models
compared to the observed testing set. In general, the boosted regression
tree model approach significantly outperformed the linear models.
Regression trees are able better capture the potential non-linearities
of the experimental dataset and can remove the negative predictions
forecast by the linear model. However, both sets of models consistently
showed $r^2 > 0.8$ correlation between observed and predicted values
with a mean prediction error of less than 4 seconds.

Of all six execution time models (2 models x 3 SDMs), the regression
tree prediction model of the MARS SDM performed the best, with a mean
error of $-0.457 \pm 1.895$ seconds and an $r^2$ value of 0.936. The
regression tree models for GAM and GBM-BRT SDMs both performed well with
r^2^ values of 0.892 and 0.880, respectively. The linear models all
showed lower r^2^ correlation values and had larger prediction variance
and mean prediction errors than their decision tree counterparts. The
best performing linear model was again for the MARS SDM, with an r^2^
correlation of 0.876, with a significantly larger mean error of
$2.17 \pm 1.73$ seconds. Figure \[fig:all\_models\] shows the observed
and predicted values for each SDM for both of the prediction models.

Model interrogation using ANOVA (linear model) and partial dependency
plots (GBM model) reveals that model execution time depends strongly on
the number of training examples used to fit the SDM. In all cases, the
number of training examples and spatial resolution of the output were
shown to be highly significant ($p < 0.001$). Computer hardware
variables were not shown to be significant predictors of execution time
for these SDMs. In some cases, additional memory was shown to reduce
model speed, perhaps due to increased overhead of memory management.
Runtime logs indicate that model execution was bounded by CPU processing
capability, rather than main memory capacity, suggesting that SDM
workflows could be improved if the algorithms were written to run in
parallel, rather than sequentially.

Within-Cell Variance
--------------------

![Within cell variance as a function of mean cell execution time. Note
the exponential increase in variance as the execution time
increases.<span
data-label="fig:var_mean"></span>](var_hist.png){width="60.00000%"}

![Within cell variance as a function of mean cell execution time. Note
the exponential increase in variance as the execution time
increases.<span
data-label="fig:var_mean"></span>](var_mean.png){width="60.00000%"}

One of the major questions raised by the computer science literature on
this topic is that there may be stochastic variations due to
unpredictable system processes and hardware design that will cause a
predictive model to fail. Here, I evaluate the within-cell variance of
the preliminary results. I have done ten (n=10) replicates of each
combination of experimental variables, so I am relatively confident in
evaluating the magnitude of the variations. The median within-cell
variance is 115 seconds, which is a significant amount of time. The
standard deviation of the variance is 388 seconds. Figure
\[fig:var\_hist\] illustrates the distribution of the within-cell
variance. The variance also appears to increase as execution time
increases, suggesting that predictions on longer-running models are less
robust than on short-running processes. Figure \[fig:var\_mean\] shows a
strong exponential increase in variance as cell mean execution time
increases.

Resource Utilization
--------------------

![Resource utilization during modeling runs.<span
data-label="fig:resource_usage"></span>](resource-usage.jpg){width="60.00000%"}

Flummoxed by the apparent lack of influence of the hardware variables on
execution time, I monitored the runtime environment of the models and
recorded CPU and memory utilization as the models were being executed.
These data show the models are bounded by sequential algorithm design,
and thus CPU utilization, and have very modest memory requirements.
Figure \[fig:resource\_usage\] shows the data. Clearly, the models max
out a single core (bottom, left side) but are unable to extend utilize
more than this when given an additional core to work with (bottom, right
side). For memory, we see that all of the experiments use the same
amount of memory (1.5 GB). This amount of memory is less than the
smallest memory configuration I tested on (2GB), so adding additional
memory does not influence results. The top panel in Figure
\[resource\_usage\] shows the percentage used memory over different
memory types. As total memory increases, percent used decreases, hence
the structure of the figure.

Discussion
==========

I am really surprised by the lack of trends due to the hardware
variables. Increasing memory actually shows a statistically significant
increase in execution time. I’m not sure what ti make of this, unless
it’s because I am not coming close to maxing out the memory. This is
possible – the datasets are are only 20-25 MB each and the predictor
variable stacks are between 5 and 15 MB, depending on spatial
resolution. The smallest memory configuration I used was 600MB, so
perhaps it didn’t fill up with this small of datasets. I have logs for
some of the lower memory instances, and it does appear that a large
portion of the memory remains free. In the future, I can better monitor
the percentage of memory usage and match it to the computing time.

The addition of vCPU cores is similarly confounding. The boosted
regression tree function I’m using in R (from the dismo package) relies
on the gbm package. This package has the option to run the model cross
validation on multiple CPU cores. The default to this function is to run
the CV on parallel::detectCores() cores, which I know to be working,
because I use this function to find the number of cores of each machine
as they initialize themselves. dismo::gbm.step() calls the
gbm::gbm.fit() function with n.cores set to NULL, which triggers the
default behavior. Thus, I believe that the function should be completing
the CV on multiple cores. While this is a relatively small portion of
the total code, it should at least slightly influence the execution
time. The logs I have indicate that perhaps 50% of the CPU capacity was
used, so similar to memory, I think I’m just not taxing the system
enough. Another note with these hardware variables is that I am running
them on dedicated computers, not under normal desktop load (like you
would find in the wild), so my results likely underestimate the stress
put on the memory and processor. In a real-world lab, you’d likely be
running many other processes, which would take away CPU and memory
capacity from the SDM models.

The predictive models are surprisingly good at predicting the execution
time from an independent testing set. However, I think that this is due
almost completely to the number of training examples predictor, which is
strongly correlated with the resulting total time. Furthermore, I can
come close to predicting the mean response time but the standard
deviation of the errors is large, so I don’t have much confidence in
either the GBM or multiple regression models as predictive tools.

The within-cell variance is also concerning. Not only is it large, but
it appears that it increases with execution time, indicating that it
will be harder to predict longer running processes. Perhaps there is
another hardware (or algorithm input) variable that I can use to reduce
the within-cell variance and better capture the responses.

On the positive side, I’ve fully developed a modeling workflow that
works in a distributed environment on the cloud. It works as expected (I
think), ties into a central database, is easy to maintain and simple to
download the results set. I think this is a really excellent start, and
even if I have to start over from scratch on the experimental design,
this will be a good framework to re-use. I have also learned a ton about
computers and the SDM model code and inner workings.

Furthermore, even from the limited data, I can start to make statements
about the effect of adding training examples to the models. While there
is some literature about assessing the accuracy of models as a result of
training examples, few experiment with finding the optimal number of
training examples to maximize accuracy. I think that there is some value
in being able to estimate accuracy from the number of occurrence points
that you start with.

What Next
=========

My task now is to determine whether to be patient and continue with the
experimental protocol I have developed, or to refine the experimental
design and start over. Given what I have so far, I think it is safe to
say that in the best of circumstances (i.e., with no other running
processes) standard boosted regression tree SDMs do not require anything
more than the most simple of computers. However, that’s not that
interesting of a finding, and will be difficult to write about. Also, I
don’t think that this is a typical scenario, as most researchers will be
using the computers for multiple foreground and background tasks during
the modeling workflow (e.g., email, RStudio GUI, solitaire, etc). An
interesting comparison would be to correlate the cloud results with the
same experiments run on a traditional desktop.

I think that the preliminary results can be used as a baseline result,
showing that simple models can be run quickly and efficiently on
standard desktops, but I think that it is necessary to refine the
protocol and design some experiments that will really stress even the
larger computer configurations. Some ideas that I think might fit the
bill:

1.  Use community-level models to develop responses for multiple taxa in
    one go,

2.  Use more predictors than just the five I am currently running. This
    has accuracy and overfitting implications,

3.  Test other SDM algorithms (GLM, GAM, SVM, etc). This is an easy way
    out, since it’s just a couple of lines of code to change, but I
    doubt that if GBMs don’t respond to hardware factors that other
    simple models with either,

4.  Re-code a GBM function that is more explicitly parallel. There is
    some literature on this, but it would likely make a minimal
    difference, and is probably beyond my ability,

5.  Expand study area from North America to the whole world. This would
    increase the memory needed to store and project the output,

6.  Fit the model on even more training points (say &gt;100,000)

I think of all of these solutions, the best would be using community
level models or more computationally intensive SDMs, perhaps with some
of the others mixed in (e.g., with more training examples at a larger
spatial scale).
