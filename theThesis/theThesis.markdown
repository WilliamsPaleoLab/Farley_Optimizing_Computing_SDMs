## A User-Centered Approach to Computing Optimization in Ecological Modeling Workflows
### Scott Sherwin Farley
### Master's Thesis Living Document
### Advisor John W. Williams

# Introduction
Global environmental change, specifically climate warming and anthropogenic land use change threatens to severely alter biodiversity patterns worldwide. Rates of extinction are increasing and habitat fragmentation and change is likely to be a major factor in determining changes in species occurrence over the foreseeable future.  Species ranges are thought to be primarily climate-induced, though other factors, such as other species, may also have significant influence.  Using statistical methods, ecologists often forecast the distribution of plant and animal species into the future under different warming scenarios.  

Though climate change is threatening to dramatically alter the distribution of species on the earth, scientists are in a good position to forecast and adapt to the coming changes.  Environmental monitoring efforts, such as the Long Term Ecological Research Network (LTERN), National Ecological Observatory Network (NEON), and the Paleocological Observatory Network (PalEON), community curated databases, like the Neotoma Paleoecological Database and the Paleobiology Database (PBDB), and modern biodiversity occurrence databases, such as the Global Biodiversity Information Facility (GBIF), are coming to fruition to support global scale environmental change synthesis efforts. New information storage facilities provide a tremendous amount of information to researchers attempting to understand how the earth system will change during the next century.  However, as the volume and variety of data increases, so do the challenges associated with dealing with what can now be considered Big Data.  While ecological data may in the past have not been considered Big Data, the massive influx of new data clearly requires new techniques to derive insight from the data.

Insight in Big Data is derived from statistical modeling or 'data mining' of the dataset. As datasets grow, the statistical methods used to mine them grow in complexity. Massive datasets, like the popular microblogging service Twitter, require distributed, parallel, streaming models to determine trending topics and other important factors of the real time data stream.  Ecologists have begun to apply some sophisticated machine learning techniques to ecological forecasting techniques, and have seen excellent predictive ability in applying these methods.  However, traditional methods in ecology, even those methods at the contemporary cutting edge of the field, are not suited to the large influx of data coming into databases each year.  Ecological modelers need to look ahead to a time when there will be over a billion occurrence records in repositories like GBIF, an event that is likely to occur by 2020 [check exact date on this, and cite]. With so many records to work with, ecologists will need to adopt techniques more often associated with fields like geonomics, including distributed processing, ensemble methods, and cloud computing.

Data on paleoenvironmental proxies, including fossil pollen, macrofossils, and freshwater and marine diatoms, add additional information to ecological data collected in the modern era.  The addition of paleodata to questions of biogeography and species niches can help researchers come closer to approximating a species' fundamental niche rather than its realized niche [@Veloz:2012jw], which is characterized by the modern data. Furthermore, including paleodata can shed light on species responses to climates that do not currently persist on the globe today.  Williams and Jackson [@Williams:2007iwa], not the high probability of encountering novel and no modern analog climates in the near future.

Climate-driven ecological forecasting models, also known as species distribution models (SDMs) have seen extensive use in the ecological discipline, including global change biology, evolutionary biogeography(@Thuiller:2008enb, [@Araujo:2005jy]), reserve selection [@Guisan:2013hqa], and invasive species management [@Ficetola:2007bn].  These models are used by ecologists, land managers, and biologists to characterize a species' biospatial patterns over environmental gradients [@Franklin:2010tn]. These models use model-driven (statistical) or data-driven (machine-learning) techniques to develop a functional approximation of the way in which a species responds to a climatic gradient.  A trend towards computationally intensive modeling approaches, including Bayesian methods that rely on repeated sampling of full joint probability distributions [@Dawson:2016wa], is apparent in recent years.  These methods utilize occurrence data -- places where a species presence was recorded -- and the environmental covariates to those places as input into the model, regardless of the algorithm chosen to develop the response surface.  As more occurrence data becomes available through portals such as GBIF and Neotoma, these models become increasingly complex. Sequential learning methods, while seeing widespread use in the literature and have demonstrated high predictive accuracy, are not scalable to very large datasets. To date, it has often been acceptable to cut back on amount of modeling, or focus of a study, to comply with computational limitations.  However, as more data becomes available to modelers, this will no longer be a viable option [NEED TO CITE].

Cloud computing offers a technological solution to some of the problems posed by the increasing Bigness of ecological data.  Cloud computing refers to a broad category of computer architectural design patterns that enable "ubiquitous, convenient, and on-demand network access to a shared pool of configurable computing resources that can be rapidly provisioned and released with minimal management effort" ([@Mell:2012jj], [@Hassan:2011uh], [@Anonymous:mc8EfgMa]). With the rapid commercialization and popularization of cloud computing, scientists have, in practice, an unlimited supply of configurable computing resources at their disposal, with the only practical barrier to their use being the ability to afford to 'rent' the resources.  The Cloud has been advertised by many of Silicon Valley's biggest players as the net big thing in the technology industry. It has been credited with Obama's 2012 presidential election win, Netflix's ability to provide streaming entertainment to millions of consumers, and Amazon's massive success in online retailing ([@Mosco:2014cu]).  The National Aeronautics and Space Administration (NASA) and the National Science Foundation (NSF) have both officially endorsed the updating of constituent computing system to include Cloud technology [@Mosco:2014cu].  In the geospatial sciences specifically, the cloud has been posited as the future of geospatial computing and modeling [@Yang:2011bd].  

Although the cloud seems promising to supports ecology's entry into the Big Data world, it is not a pancea, as there is to-date little guidance on when the benefits, in reduced computing time, outweigh the costs of a cloud-based solution. The Cloud works on an entire different model of computing cost than traditional scientific computing.  Transitioning to the cloud comes with a transition away from large, up front captial expenses to a model of monthly usage fees -- an operational expense model [@Hassan:2011uh].  In the captial expense model, the computing power must be determined in advance, and users are locked into the level of performance they choose at the time of purchase.  Under the cloud model, on the other hand, users may scale up or scale down the number and quality of computing resource they have, or even configure the system to automatically scale the number of resources to the task at hand using a computer algorithm as the load on the server changes.  Along with a transition away from traditional desktop computing to cloud solutions comes a marked increase in the complexity of the solutions.  Cloud-based solutions are exceptionally complex to set up and maintain, especially for those not experienced in using virtual instances, shell scripting, and IT management.  While the complexity costs of engineering and implementing a cloud based solution are difficult to estimate, the computational time gains achieved by running models on faster computers can be measured empirically and combined with estimates of cost per hour to provide guidance on when a cloud based solution would be economically rational.

In this thesis, I develop a theoretical framework to determine the optimal computing solution for a given species distribution modeling workflow. I treat the workflow characteristics as model parameters, and then build a theoretical predictive model that minimizes the time cost of running a computational model while simulaneously minimizes the financial cost of provisioning the computational resources for that run. I gather data on empirical runtimes of four different classes of species distribution models, and then fit a gradient boosted regression tree model to the training data.  The fitted model is capable of predicting the execution time of future modeling scenarios, even if the particular combination has not yet been seen. I evaluate the model's predictive skill and evaluate it on a SDM case study.

My findings suggest that if SDMs, and ecology more generally, is to benefit from Cloud computing, future effort must be directed towards developing models that more explicitly take advantage of parallelism and distributed processing frameworks.  Currently modeling trends are mostly sequential, and do not leverage more than one computing core.  [ADD STUFF ABOUT MEMORY WHEN WE HAVE IT].  The models I have are capable of guiding future modeling efforts in the field.  

The remainder of this thesis proceeds as follows: in the following section I introduce my research questions, motivated by the tension between a potential decrease algorithm runtime and an associated increase in computational cost.  Section 3 works with the "Four V's Framework" of Big Data to justify ecological datasets as Big Data.  Section 4 reviews relevant background literature on system benchmarking, runtime modeling, species distribution modeling, and cloud computing. In Section 5, I present a theoretical framework for predicting the optimal computing solution for a given ecological forecasting modeling. Section 6 describes the methodology used to collect runtime and accuracy data on four different SDM instances. Section 7 presents the results of the experiments and comments on their implications.  Conclusions and future work is discussed in Section 8.

2.  Research Questions
  * Might need to revise?
  i.  To what degree can the runtime of climate-driven ecological forecasting models be predicted?
    a.  Can a predictive model out-predict a null model that suggests that all researchers utilize a single desktop computer for all modeling activities?
  ii. Can an optimal solution for a given modeling workflow be predicted using workflow characteristics?
    i. If so, what are the most influential workflow characteristics in making this decision?
    ii.  Do contemporary published studies vary in the characteristics that matter most in execution time?
  iii. What modeling scenarios are best suited for transition to the cloud, if any?

3.  Justify ecological data as big data
The vast expansion of data the sciences sciences has necessitated revolutionary measures for data management, analysis, and accessibility [@Schaeffer:2008kl], [@Chen:2014fc]. Worldwide data volume doubled nine times between 2006 and 2011. Robust, expressive, computable, quantitative, accurate and precise methods are essential to the future of the biological sciences and related disciplines [@Schaeffer:2008kl].  The need for new techniques and applications to manage the growing avalanche of data is clear in nearly all scientific fields.  Climate analytics is a domain with very large data, and challenges for data management in this field include: inability to move very large datasets across networks, complex analyses on large repositories must utilize high performance computing techniques, large amounts of data require large amounts of metadata to facilitate provenance management and data discovery, and demands for new and unanticipated uses for data required greater agility in developing and deploying applications [@Schnase:2014dn]. [@Anonymous:aiu_1fsc] notes the long term trend towards large DNA sequences and argues that genomics research requires new technological systems to support the growing volume of data.

The term Big Data is typically used to describe 'enormous' datasets, typically characterized as masses of unstructured data that need more real-time analysis than traditional datasets. Big Data, while incurring new challenges, such as how to effectively organize and manage such large datasets, brings the opportunity for discovering new insights to difficult problems [@Chen:2014fc]. The precise definition of Big Data is ambiguous, though there are two prominent frameworks for discriminating Big Data from traditional data. One definition is that Big Data is "a loosely defined term used to describe data sets so large and complex that they become awkward to work with using standard statistical software" [@Snijders:2012ww].  Apache Hadoop, a popular distributed computing platform, similarly described Big Data as “datasets which could not be captured, managed, and processed by general computers within an acceptable scope” [@Chen:2014fc].  A second important framework by which to classify Big Data is the 'Four V's', first introduced by IBM and used by IBM and other large technological companies in the early 2000's to characterize their data.  Under this framework, a dataset's Bigness is described by its velocity, volume, veracity, and variety. [@Yang:2013gm] describe this framework in their fundamental text, Spatial Cloud Computing, suggesting that  “volume refers to the size of the data; velocity indicates that big data are sensitive to time, variety means big data comprise various types of data with complicated relationships, and veracity indicates the trustworthiness of the data” [@Yang:2013gm] p.276.  Using these two definitions as rubrics for describing a data's Bigness, we can discriminate Big Data from traditional data.  Using this technique, it is clear that the datasets traditionally used in ecology, particularly occurrence data, is Big Data.

Ecological occurrence data is a fundamental type of data that underpins biodiversity analyses, ecological hypothesis testing, and global change research. Occurrence data consists of presence, absence or abundance records of a particular species, clade, or higher taxonomic grouping. Ecological occurrence data is increasing stored in large, collaborative, community curated databases like the Neotoma Paleoecological Database (NeotomaDB), the Global Biodiversity Information Facility (GBIF), and the Paleobiology Database (PBDB). These database streamline the organization, storage, management, and distribution of data collected by scientists in various disciplines around the world. These databases have experienced a large increase in volume in recent years, and digital holdings of occurrence records range into the millions. While databases, particularly GBIF, have taken criticism for issues of data quality, consistency, and precision [@soberon2002issues], and spatial bias [@Beck:2014ky], they provide a low friction way to consume large amounts of data that would otherwise be prohibitively time consuming to derive from the literature or in the field [@Beck:2014ky], [@Grimm:2013uu]]. Since the early 1990s, the Internet and associated information technology and an increased willingness to share primary data are creating enabling unprecedented access to biodiversity data.  Soberon and Peterson coin the widespread availability to this data 'Biodiversity Informatics' and include the management, exploration, analysis and interpretation of primary data regarding life, particularly at the species level of organization.

Using the two frameworks of Big Data introduced above, ecological occurrence can be placed alongside geonomics and climate analytics as a field that requires specialized tools and methods to cope with the massive influx of data since the early 1990s. New techniques are required to meet the large and rapidly expanding collections of digital databases.

The Snijders et al definition of Big Data suggests that Big Data refers to datasets that are too large to utilize traditional means of analysis. Under this framework, the Bigness of the data is specific to the organization attempting to utilize it, suggesting two corollaries: 1) the volume of data that make it Big is changing, and may grow with time or as technology advances, and 2) the criteria for what constitutes Big Data can vary between problem domains [@Chen:2014fc]. [@Chen:2014fc] suggest that at present, Big Data typically refers to datasets between several terabytes and several petabytes (2^40 - 2^50 bytes), however, if we take into account the domain's history with large datasets, ecological occurrence data can be seen as Big Data.

The very existence of complex relational databases, like GBIF, Neotoma and PBDB, suggests that biodiversity data fall under the label of Big Data. While the datasets are not particularly large in storage volume, they are composed of millions of heterogenous records with complex linkages. Consider the complexity of the relationships between different data records, for example. Figure 1 shows the Neotoma relational table structure, and the complicated web of relationships between each entity. The data is both spatial and temporal, requiring these attributes, which are known to be messy, along with sample data and metadata. Now, consider keeping track of this for tens of thousands (Neotoma) or hundreds of millions (GBIF) or records, among thousands of independent researchers, and we see why non-traditional techniques like these databases have been developed. Further developments, like APIs and R packages, are even more recent developments to further simplify the tasks of accessing, filtering and working with the datasets. No, ecological biodiversity data does not meet the scale and extent of YouTube, Twitter, or Amazon, but it does require new, custom built tools to store, analyze, and use.
![Neotoma_Database_Design](img/Neotoma_ER.jpg)
Ecological biodiversity data can also be shown to be Big under the Four V's framework, demonstrating variety, veracity, and volume, though it lacks velocity. Occurrence datasets are not on the scale of billions of hours of YouTube videos or hundreds of billions of Tweets, but the scale of biodiversity data has exploded in recent years, bringing it to a place where the volume alone is challenging to manage.

Since the late 1990s, biodiversity databases have quickly and decisively increased the amount of data available to ecologists. Consider Figures [X] and [X], tracking the growth in collections of Neotoma and GBIF through time. In 1990, only 2 of the records now stored in Neotoma were in digitized collections. Today, there are over 14,000 datasets containing [XXX] individual occurrence records, and associated spatial, temporal, and taxonomic metadata, corresponding to an average growth rate of 1.4 records per day. Nearly all records in Neotoma are derived from sedimentary coring or macrofossil extraction efforts, data gathering techniques that require large expenditures of time and effort [@Davis:1963hk], [@Glew:2002fv].  GBIF's collections are far larger than Neotoma's, perhaps reflecting the lower degree of effort required to gather modern ecological occurrence data. GBIF houses digital records of well over 600 million observations, recorded specimens (both fossil and living), and occurrences noted in the scientific literature. Since its first operation in 2001, the facility’s holdings have grown nearly 300%, from about 180 million records in 2001 to approximately 614 million  records. Managing more than 600 million records and associated metadata, and coping with such a fast growth rate, is clearly a data management challenge worthy of Big Data classification. Figure 3 shows the exponential growth in GBIF’s holdings since AD 1500. Note that GBIF's reliance on literature and museum specimens allow its holdings to extend beyond its origin in 2001.

The second characteristic of Big Data in the four V’s framework is the Variety of the data, and its ‘various types with complicated relationships’ [@Yang:2013gm]. Biodiversity data is highly diverse with many very complicated relationships and interrelationships.  Neotoma’s holdings range from XRF measurements, to geochronologic data, to fossil vertebrates, to modern pollen surface samples. In total, there are 23 dataset categories in the database. Though it is structured similarly in the database tables, each of these data types comes from a different community of researchers, using different methods and instruments. Figure 5 shows the breakdown of dataset types in the database. GBIF has 9 defined record type categories, including human observation, living specimen, literature review, and machine measurements. As with the Neotoma dataset types, these are wildly different from each other. A living specimen is clearly a totally different type of data to work with than something was derived from a literature review. Yet all of these types coexist together in these large biodiversity datasets.

To further add to the variety and complexity of our data, it is both spatial and temporal in nature, causing complicated interrelationships between data entities. 100% of Neotom's records and 87.6% of GBIF's records are georeferenced. In these databases, the spatial information is compounded by other fields that describe the location of the observation. For example, Neotoma has fields describing the site where the fossil was found – it’s altitude, environment, area. PBDB has extensive metadata for depositional environment, giving additional context to fossil occurrences. GBIF often notes somewhat colloquial location descriptions in addition to geographic coordinates. And, of course, there are the relationships between the spatial coordinates themselves – are these things in the same place? do they overlap? Managing data with a spatial component is nearly always more challenging than managing data without it [FIND GOOD QUOTE HERE].

Occurrence data's variety is also enhanced because it is the work of an many dispersed, individual researchers. The controlled vocabularies and organization policies enforced by the databases have helped to efficiently aggregate the data, however, nearly every record was collected, worked up, and published by a different scientist. While a some researchers have a very large number of datasets credited to them, most have many fewer. The median number of datasets contributed is 2, and the 3rd quartile value is just 7. Each researcher is apt to use different equipment and lab and documentation procedures, yielding a highly variable dataset.

Biodiversity data also has high levels of uncertainty associated with it, comprising the third V in the Four V's Framework. Some of the sources of uncertainty in the data, like spatial imprecision in GPS measurements [@Wing:2005wl] and temporal uncertainty in radiocarbon ages [@Blaauw:2010kg], can be estimated. Other have yet to be quantified, for example inter-researcher identification differences, measurement errors, and data lost in the transition from field to lab to database. A recent paper by the Paleon working group used expert elicitation to quantify the differences between the dates assigned to European settlement horizon, a process they argue varies between sites, and depends on the “temporal density of pollen samples, time-averaging of sediments, the rapidity of forest clearance and landscape transformation, the pollen representation of dominant trees, which can dampen or amplify the ragweed signal, and expert knowledge of the region and the late-Holocene history of the site.” The findings of this exercise suggest that paleoenvironmental inference from proxy data is highly variable between researchers.  Moreover, some information will undoubtedly be lost in the process of going from a field site through a lab workflow to being aggregated in the dataset. Not all process details can be incorporated into database metadata fields, and probably more importantly, contextual details essential to proper interpretation of the data often gets lost on aggregation.

The datasets in Neotoma and GBIF suggest high levels of the types of uncertainty that can be quantified, and are apt to show high levels of unquantifiable uncertainty as well. Of a random sample of 10,000 records of the genus *Picea* from GBIF, over half did not report spatial coordinate uncertainty. Of the 4,519 records that did, the average uncertainty was 305 meters, and the maximum was 1,970 meters. Clearly, such high levels of uncertainty might be problematic for modeling efforts [@Beck:2014ky]. Neotoma records show a similar uncertainty in their temporal information. Neotoma records each have a minimum, maximum, and most likely age for each age control point (e.g., radiocarbon date). Out of a sample of 32,341 age controls in the database, only 5,722 reported any age uncertainty at all. The summary statistics for these age controls suggest that the median age model tie point has a temporal uncertainty of 260.0 years. The 25% percentile is an uncertainty of 137.5 years and the 75% 751.2 years, suggesting that dates are only identifiable down to ± 130 years of the actual date. [NEOTOMA UNCERTAINTY THROUGH TIME]. Considering sediment mixing, laboratory precision, and other processes at work this is a relatively minor uncertainty, but it contributes to occurrence data's lack of veracity.

The final piece of the framework is velocity, which characterizes the time sensitivity of the dataset. High velocity data must be analyzed in real time as a stream to produce meaningful insights. Tweets, for example, must be analyzed for trends as they are posted. Significant effort has been put towards sophisticated algorithms that can detect clusters and trends in real time [@Kogan:2014hh], [@Bifet:2011wa]. The rate of increase in data volume in both Neotoma and GBIF is not fast enough to invalidate the results from previous analyses, suggesting that it's velocity is not enough to warrant Big Data techniques. Neotoma's growth rate of approximately 1.4 new datasets each day (1990-2016 average) and GBIF's rate of about 59,000 new occurrences each day (2000-2015 average) are small compared to the total number records in the database.  While the volume of data being added to the repositories each year is large in total number, it does not warrant the use of specialized streaming algorithms for extracting information from the new data points. Unlike in many business applications, there is little incentive to researchers to immediately analyze new biodiversity records, since all new findings will be reported on in the academic paper cycle, typically several months to years. Moreover, automated analyses of distributions have been warned against, primarily due to the lack of data quality mentioned previously [@soberon2002issues].

Thus, ecological occurrence data is Big Data, and requires sophisticated techniques to derive insight from it.  Traditional techniques for storage analysis are unlikely to be suitable in the coming years due to the massive influx of data records each year. Both GBIF and Neotoma have experience sustained and increasing growth over the last two decades.  While the database and storage facilities for these data have changed to accommodate the growing data volume, the models and analysis techniques have yet to change significantly.  The modeling algorithms used in ecological data analysis should be reevaluated to bring them into the world of big data.  

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
