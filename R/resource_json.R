p= 0
for (p in 1:length(memory.data)){
  name <- memory.names[[p]]
  print(name)
  lab <- strsplit(name, "-")[[1]]
  cores <- lab[2]
  GB <- lab[3]
  grp <- paste(cores, GB, sep="_")
  grp
  memory.data[[p]]$cores = cores
  memory.data[[p]]$GB <- GB
  memory.data[[p]]$series <- name
  memory.data[[p]]$grp <- grp
}
x <- melt(memory.data, id.vars = c("series", "ts", "grp", "cores", "GB"), measure.vars="val")
x <- x[-which(x$ts < 1467975000), ]
x <- x[-which(x$grp == '2_4'),]

p1 <- ggplot(x, aes(x=as.POSIXct(ts, origin="1970-01-01"), y=100- value * 100,  group=factor(grp), color=factor(grp)))+   geom_point() + geom_line() + labs(x = "Time of Measurement", y='Used Memory', title="Used Memory")

p= 0
for (p in 1:length(comp.data)){
  name <- comp.names[[p]]
  print(name)
  lab <- strsplit(name, "-")[[1]]
  cores <- lab[2]
  GB <- lab[3]
  grp <- paste(cores, GB, sep="_")
  grp
  comp.data[[p]]$series <- name
  comp.data[[p]]$grp <- grp
}

j <- melt(comp.data, id.vars = c("series", "ts", "grp"), measure.vars="val")
j <- j[-which(j$ts < 1467975000), ]
j <- j[-which(j$grp == '1_1'), ]
j <- j[-which(j$grp == 'database_5'),]

p2 <- ggplot(j, aes(x=as.POSIXct(ts, origin="1970-01-01"), y=value * 100,  group=factor(grp), color=factor(grp)))+   geom_point() + geom_line() + labs(x = "Time of Measurement", y='Used CPU', title="Used CPU")


#p2 <- ggplot(melted, aes(x=as.POSIXct(ts, origin="1970-01-01"), y=value * 100,  group=factor(grp), color=type))+   geom_point() + labs(x = "Time of Measurement", y='Percent Usage', title="Resource Utilization")

multiplot

# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}