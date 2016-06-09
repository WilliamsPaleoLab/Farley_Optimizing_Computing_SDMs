CREATE TABLE IF NOT EXISTS SessionsManager(
	sessionID BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE,
    sessionStatus text,
    cellsRun integer,
    repliatesRun integer,
    sessionStart timestamp DEFAULT current_timestamp,
    sessionEnd timestamp DEFAULT current_timestamp,
    primary key(sessionID)
);

CREATE TABLE IF NOT EXISTS  SessionsR(
	rSessionID BIGINT UExperimentsNSIGNED NOT NULL AUTO_INCREMENT UNIQUE,
    sessionID BIGINT,
    rPlatform text,
    rVersion text,
    rNickname text,
    
    foreign key(sessionID) references SessionsManager(sessionID) ON DELETE CASCADE
);

CREATE TABLE  IF NOT EXISTS SessionsComputer(
	computerSessionID BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE,
    sessionID bigint,
    osFamily text,
    osRelease text,
    osVersion text,
    nodeName text,
    architecture text,
    numCPU text,
    threadsPerCPU text,
    cpuVendor text,
    cpuModelNumber text,
    cpuMdelName text,
    cpuClockRate text,
    cpuMPIS text,
	hypervisor text,
    virtualization text,
    L1d text,
    L1i text,
    L2 text,
    L3 text,
	
    foreign key (sessionID) references SessionsManager(sessionID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Experiments (
    experimentID BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE,
    sessionID BIGINT,
    cellID INTEGER,
    replicateID INTEGER,
    cores INTEGER,
    GBMemory BIGINT,
    taxon TEXT,
    trainingExamples INTEGER,
    spatialResolution INTEGER,
    experimentName TEXT,
    experimentCategory TEXT,
    experimentStatus TEXT,
    experimentStart TIMESTAMP,
    experimentEnd TIMESTAMP,
    experimentLastUpdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (experimentID),
    FOREIGN KEY (sessionID)
        REFERENCES SessionsManager (sessionID)
);

CREATE TABLE  IF NOT EXISTS Results(
	resultID BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE,
    experimentID bigint,
    sessionID bigint,
    pollenThreshold double precision,
    presenceTHreshold double precision,
    totalTime double precision,
    fittingTime double precision,
    predictionTime double precision,
    accuracyTime double precision,
    testingAUC double precision,
    testingOmmissionRate double precision,
    testingSensitivity double precision,
    testingSpecificity double precision,
    testingPC double precision,
    testingKappa double precision,
    nTrees integer,
    meanCVDeviance double precision,
    seCVDeviance double precision,
    meanCVCorrelation double precision,
    seCVCorrelation double precision,
    meanCVROC double precision,
    seCVROC double precision,
    trainingResidualDeviance double precision,
    trainingTotalDeviance double precision,
    trainingCorrelation double precision,
    trainingROC double precision,
    inputTime timestamp default current_timestamp,
    primary key(resultID),
    foreign key (experimentID) references Experiments(experimentID) ON DELETE CASCADE,
    foreign key (sessionID) references SessionsManager(sessionID) ON DELETE CASCADE
);