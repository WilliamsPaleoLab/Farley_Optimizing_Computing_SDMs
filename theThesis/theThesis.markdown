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
Ecological occurrence data is sometime referred to as Big Data. but what characteristics of the dataset makes it Big? Big Data is typically referenced in relation to corporate applications like the video sharing giant YouTube, which supports hundreds of millions of hours of watchtime per year, Twitter, which generates over 500 million microblog posts per day, and Facebook, which claims to maintain a 300 petabyte image database (https://code.facebook.com/posts/229861827208629/scaling-the-facebook-data-warehouse-to-300-pb/). Ecological data is increasing at an extremely fast rate, but there aren't millions or billions of ecologists and the scale of the data used in the field is not on par with these technological giants.  Using a Big Data framework

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
