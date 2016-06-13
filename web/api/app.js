//Module imports
var http = require('http');
var express = require("express");
var dispatcher = require('httpdispatcher');
var mysql = require('mysql');

var app = express()

var bodyParser = require('body-parser');

// configure app to use bodyParser()
// this will let us get the data from a POST
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

var router = express.Router();

hostname = '104.154.235.236'
username = 'Scripting'
password = 'Thesis-Scripting123!'
db = 'timeSDM'

//Serve on this port
const PORT=8080;

// //Handle different HTTP verbs
// function handleRequest(request, response){
//     try {
//         //log the request on console
//         console.log(request.url);
//         //Disptach
//         dispatcher.dispatch(request, response);
//     } catch(err) {
//         console.log(err);
//     }
// }

// //Create a server
// var server = http.createServer(handleRequest);


function createDBConnection(host, db, password, user){
  var connection = mysql.createConnection({
    host     : host,
    user     : user,
    password : password,
    database : db,
    multipleStatements: true
  });
  connection.connect();
  return connection
}

// middleware to use for all requests
router.use(function(req, res, next) {
    // do logging
    console.log('Something is happening.');
    next(); // make sure we go to the next routes and don't stop here
});


app.get("/sessions", function(req,res){
  connection = createDBConnection(hostname, db, password, username)
  //get the query params
  var sessionStatus = req.query.sessionStatus
  var numCPUs = req.query.numCPU
  vars = {sessionStatus: sessionStatus, numCPU: numCPUs}
  sql = "SELECT * FROM SessionsManager "
  sql += "INNER JOIN SessionsComputer on SessionsComputer.sessionID = SessionsManager.sessionID "
  sql += "INNER JOIN SessionsR on SessionsR.sessionID = SessionsManager.sessionID"
  sql += " WHERE (? IS NULL or ? = lower(sessionStatus)) "
  sql += " AND (? IS NULL or ? = numCPU );"

    connection.query({sql : sql,  values : [sessionStatus, sessionStatus, numCPUs, numCPUs]}, function(err, results){
      if(!err) {
        out = {
          success :true,
          timestamp: new Date().toLocaleString(),
          data : results,
          message: ""
        }
          res.json(out);
      }else{
        out = {
          success: false,
          timestamp : new Date().toLocaleString(),
          data: [],
          message: err
        }
        res.json(out)
      }
    })
});


app.get("/sessions/:sessionID", function(req,res){
  sessionID = req.params.sessionID
  connection = createDBConnection(hostname, db, password, username)
  //get the query params
  var sessionStatus = req.query.sessionStatus
  var numCPUs = req.query.numCPU
  vars = {sessionStatus: sessionStatus, numCPU: numCPUs}
  sql = "SELECT * FROM SessionsManager "
  sql += "INNER JOIN SessionsComputer on SessionsComputer.sessionID = SessionsManager.sessionID "
  sql += "INNER JOIN SessionsR on SessionsR.sessionID = SessionsManager.sessionID"
  sql += " WHERE SessionsManager.sessionID = ?"

    connection.query({sql : sql,  values : [sessionID]}, function(err, results){
      if(!err) {
        out = {
          success :true,
          timestamp: new Date().toLocaleString(),
          data : results,
          message: ""
        }
          res.json(out);
      }else{
        out = {
          success: false,
          timestamp : new Date().toLocaleString(),
          data: [],
          message: err
        }
        res.json(out)
      }
    })
});

app.get("/experiments", function(req,res){
  experimentStatus = req.query.status
  numTrainingExamples = req.query.numExamples
  spatialResolution = req.query.spatialResolution
  CPUs = req.query.CPUs
  memory = req.query.memory
  taxon = req.query.taxon
  category = req.query.category
  limit = req.query.limit
  offset = req.query.offset
  sessionID = req.query.sessionID
  if (limit == undefined){
    limit = 1000
  }
  if (offset == undefined){
    offset = 0
  }
  connection = createDBConnection(hostname, db, password, username)
  sql = "SELECT * FROM Experiments "
  sql += "WHERE 1 = 1 AND (? is NULL or BINARY ? = lower(experimentStatus)) "
  sql += " AND (? is NULL or ? = trainingExamples) "
  sql += " AND (? is NULL or ? = spatialResolution)"
  sql += " AND (? is NULL or ? = cores) "
  sql += " AND (? is NULL or ? = GBMemory)"
  sql += " AND (? is NULL or ? like lower(taxon) ) "
  sql += " AND (? IS NULL or ? like lower(experimentCategory) ) "
  sql += " AND (? IS NULL or ? = sessionID) "
  sql += "GROUP BY cellID "
  sql += " LIMIT ? OFFSET ?"
    connection.query({sql : sql,  values :
      [experimentStatus, experimentStatus, numTrainingExamples,
        numTrainingExamples, spatialResolution, spatialResolution, CPUs, CPUs,
        memory, memory, taxon, taxon, category, category, sessionID, sessionID, limit, offset]}, function(err, results){
      if(!err) {
        out = {
          success :true,
          timestamp: new Date().toLocaleString(),
          data : results,
          message: ""
        }
          res.json(out);
      }else{
        out = {
          success: false,
          timestamp : new Date().toLocaleString(),
          data: [],
          message: err
        }
        res.json(out)
      }
    })
});

app.get("/experiments/:experimentID", function(req,res){
  expID = req.params.experimentID
  connection = createDBConnection(hostname, db, password, username)
  sql = "SELECT * FROM Experiments "
  sql += "WHERE experimentID = ?;"
    connection.query({sql : sql,  values :
      [expID]}, function(err, results){
      if(!err) {
        out = {
          success :true,
          timestamp: new Date().toLocaleString(),
          data : results,
          message: ""
        }
          res.json(out);
      }else{
        out = {
          success: false,
          timestamp : new Date().toLocaleString(),
          data: [],
          message: err
        }
        res.json(out)
      }
    })
});
app.get("/experiments/:cellID/:replicateID", function(req,res){
  cellID = req.params.cellID
  repID = req.params.replicateID
  connection = createDBConnection(hostname, db, password, username)
  sql = "SELECT * FROM Experiments "
  sql += "WHERE cellID = ? AND replicateID = ?"
    connection.query({sql : sql,  values :
      [cellID, repID]}, function(err, results){
      if(!err) {
        out = {
          success :true,
          timestamp: new Date().toLocaleString(),
          data : results,
          message: ""
        }
          res.json(out);
      }else{
        out = {
          success: false,
          timestamp : new Date().toLocaleString(),
          data: [],
          message: err
        }
        res.json(out)
      }
    })
});

app.get("/results", function(req,res){
  experimentStatus = req.query.status
  numTrainingExamples = req.query.numExamples
  spatialResolution = req.query.spatialResolution
  CPUs = req.query.CPUs
  memory = req.query.memory
  taxon = req.query.taxon
  category = req.query.category
  limit = req.query.limit
  offset = req.query.offset
  sessionID = req.query.sessionID
  minTotalTime = req.query.minTotalTime
  maxTotalTime = req.query.maxTotalTime
  minTestingAUC = req.query.minTestingAUC
  maxTestingAUC = req.query.maxTestingAUC
  if (limit == undefined){
    limit = 1000
  }
  if (offset == undefined){
    offset = 0
  }
  connection = createDBConnection(hostname, db, password, username)
  sql = "SELECT * FROM Results "
  sql += " INNER JOIN Experiments on Experiments.experimentID = Results.experimentID "
  sql += "WHERE 1 = 1 AND (? is NULL or ? LIKE lower(experimentStatus)) "
  sql += " AND (? is NULL or ? = trainingExamples) "
  sql += " AND (? is NULL or ? = spatialResolution)"
  sql += " AND (? is NULL or ? = cores) "
  sql += " AND (? is NULL or ? = GBMemory)"
  sql += " AND (? is NULL or ? like lower(taxon) )"
  sql += " AND (? IS NULL or ? like lower(experimentCategory) ) "
  sql += " AND (? IS NULL or ? = Experiments.sessionID) "
  sql += " AND (? IS NULL or ? > totalTime) "
  sql += " AND (? IS NULL or ? < totalTime) "
  sql += " AND (? IS NULL or ? > testingAUC) "
  sql += " AND (? IS NULL or ? < testingAUC) "
  sql += " LIMIT ?, ?"
  console.log(limit)
  console.log(offset)
    connection.query({sql : sql,  values :
      [experimentStatus, experimentStatus, numTrainingExamples,
        numTrainingExamples, spatialResolution, spatialResolution, CPUs, CPUs,
        memory, memory, taxon, taxon, category, category, sessionID, sessionID,
        minTotalTime, minTotalTime, maxTotalTime, maxTotalTime,
        minTestingAUC, minTestingAUC, maxTestingAUC, maxTestingAUC,
        offset, limit]}, function(err, results){
      if(!err) {
        out = {
          success :true,
          timestamp: new Date().toLocaleString(),
          data : results,
          message: ""
        }
          res.json(out);
      }else{
        out = {
          success: false,
          timestamp : new Date().toLocaleString(),
          data: [],
          message: err
        }
        res.json(out)
      }
    })
});

app.get("/results/:experimentID", function(req, res){
  experimentID = req.params.experimentID
  sql = "SELECT * FROM Results INNER JOIN Experiments on Experiments.experimentID = Results.experimentID "
  sql += " WHERE Results.experimentID = ?"
  connection = createDBConnection(hostname, db, password, username)
  connection.query({sql : sql,  values :
    [experimentID]}, function(err, results){
    if(!err) {
      out = {
        success :true,
        timestamp: new Date().toLocaleString(),
        data : results,
        message: ""
      }
        res.json(out);
    }else{
      out = {
        success: false,
        timestamp : new Date().toLocaleString(),
        data: [],
        message: err
      }
      res.json(out)
    }
  })
})

app.get("/results/:cellID/:replicateID", function(req, res){
  cellID = req.params.cellID
  replicateID = req.params.replicateID
  sql = "SELECT * FROM Results INNER JOIN Experiments on Experiments.experimentID = Results.experimentID "
  sql += " WHERE Results.cellID = ? AND Results.replicateID = ?"
  connection = createDBConnection(hostname, db, password, username)
  connection.query({sql : sql,  values :
    [cellID, replicateID]}, function(err, results){
    if(!err) {
      out = {
        success :true,
        timestamp: new Date().toLocaleString(),
        data : results,
        message: ""
      }
        res.json(out);
    }else{
      out = {
        success: false,
        timestamp : new Date().toLocaleString(),
        data: [],
        message: err
      }
      res.json(out)
    }
  })
})
app.get("/", function(req, res){
  j = {
    success :true,
    timestamp: new Date().toLocaleString(),
    directory: {
      sessions: "http://104.154.235.236:8080/sessions",
      experiments: "http://104.154.235.236:8080/experiments",
      results: "http://104.154.235.236:8080/results",
      openSessions: "http://104.154.235.236:8080/sessions?sessionStatus=STARTED",
      openExperiments: "http://104.154.235.236:8080/experiments?experimentStatus=STARTED"
}
  }
  res.json(j)
})

app.get("/", function(req, res){
  j = {
    success :true,
    timestamp: new Date().toLocaleString(),
    directory: {
      sessions: "http://104.154.235.236:8080/sessions",
      experiments: "http://104.154.235.236:8080/experiments",
      results: "http://104.154.235.236:8080/results"
    }
  }
  res.json(j)
})

app.get("/statistics", function(req, res){
  experimentStatus = req.query.status
  numTrainingExamples = req.query.numExamples
  spatialResolution = req.query.spatialResolution
  CPUs = req.query.CPUs
  memory = req.query.memory
  taxon = req.query.taxon
  category = req.query.category
  limit = req.query.limit
  offset = req.query.offset
  sessionID = req.query.sessionID
  minTotalTime = req.query.minTotalTime
  maxTotalTime = req.query.maxTotalTime
  minTestingAUC = req.query.minTestingAUC
  maxTestingAUC = req.query.maxTestingAUC
  replicateID = req.params.replicateID
  values = [experimentStatus, experimentStatus, numTrainingExamples,
          numTrainingExamples, spatialResolution, spatialResolution, CPUs, CPUs,
          memory, memory, taxon, taxon, category, category, sessionID, sessionID,
          minTotalTime, minTotalTime, maxTotalTime, maxTotalTime,
          minTestingAUC, minTestingAUC, maxTestingAUC, maxTestingAUC,
          offset, limit]
  sql = "SELECT AVG(totalTime), MAX(totalTime), MIN(totalTime), STD(totalTime), variance(totalTime), Count(totalTime), "
  sql += "AVG(testingAUC), MAX(testingAUC), MIN(testingAUC), STD(testingAUC), variance(testingAUC),  Count(testingAUC), "
  sql += " Experiments.cores, Experiments.GBMemory, Experiments.trainingExamples, Experiments.spatialResolution, Experiments.taxon, Experiments.experimentCategory, Experiments.cellID "
  sql += " FROM Results INNER JOIN Experiments on Experiments.experimentID = Results.experimentID "
  sql += " WHERE 1 = 1 AND (? is NULL or ? LIKE lower(Experiments.experimentStatus)) "
  sql += " AND (? is NULL or ? = Experiments.trainingExamples) "
  sql += " AND (? is NULL or ? = Experiments.spatialResolution)"
  sql += " AND (? is NULL or ? = Experiments.cores) "
  sql += " AND (? is NULL or ? = Experiments.GBMemory)"
  sql += " AND (? is NULL or ? like lower(Experiments.taxon) )"
  sql += " AND (? IS NULL or ? like lower(Experiments.experimentCategory) ) "
  sql += " AND (? IS NULL or ? = Experiments.sessionID) "
  sql += " AND (? IS NULL or ? > Results.totalTime) "
  sql += " AND (? IS NULL or ? < Results.totalTime) "
  sql += " AND (? IS NULL or ? > Results.testingAUC) "
  sql += " AND (? IS NULL or ? < Results.testingAUC) "
  sql += " GROUP by Results.cellID; ";
  console.log(sql)
  connection = createDBConnection(hostname, db, password, username)
  connection.query({sql : sql,  values :
    values}, function(err, results){
    if(!err) {
      out = {
        success :true,
        timestamp: new Date().toLocaleString(),
        data : results,
        message: ""
      }
        res.json(out);
    }else{
      out = {
        success: false,
        timestamp : new Date().toLocaleString(),
        data: [],
        message: err
      }
      res.json(out)
    }
  })
})


app.get("/newconfigs", function(req, res){
  CPUs = req.query.CPUs
  memory = req.query.memory
  limit = req.query.limit
  offset = req.query.offset
  status = req.query.status
  sql = "SELECT cores, GBMemory from Experiments WHERE BINARY experimentStatus='NOT STARTED' "
  sql += "AND (? IS NULL or ? = cores) AND (? IS NULL or ? = GBMemory) GROUP BY cores, GBMemory;"
  connection = createDBConnection(hostname, db, password, username)
  values = [CPUs, CPUs, memory, memory, offset, limit]
  connection.query({sql : sql,  values :
    values}, function(err, results){
    if(!err) {
      out = {
        success :true,
        timestamp: new Date().toLocaleString(),
        data : results,
        message: ""
      }
        res.json(out);
    }else{
      out = {
        success: false,
        timestamp : new Date().toLocaleString(),
        data: [],
        message: err
      }
      res.json(out)
    }
  })
})

app.get("/configstatus/:cores/:memory", function(req, res){
  CPUs = req.params.cores
  memory = req.params.cores
  connection = createDBConnection(hostname, db, password, username)
  sql = "SELECT count(*) from Experiments WHERE cores = ? and GBMemory = ?;" //get the total expected number
  sql += " SELECT count(*) from Experiments WHERE cores = ? and GBMemory = ? AND BINARY experimentStatus = 'DONE'; " // get the number that have finished
  sql += " SELECT count(*) from Experiments WHERE cores = ? AND GBMemory = ? AND BINARY experimentStatus = 'ERROR'; " // get the number that have errored out
  sql += " SELECT count(*) from Experiments WHERE cores= ? AND GBMemory = ? AND BINARY experimentStatus = 'NOT STARTED'; "
  sql += " SELECT count(*) from Experiments WHERE cores= ? AND GBMemory = ? AND BINARY experimentStatus = 'STARTED' ;"
  sql += " SELECT count(*) from Experiments WHERE cores= ? AND GBMemory = ? AND BINARY experimentStatus = 'REMOVED'; "
  sql += " SELECT count(*) from Experiments WHERE cores= ? AND GBMemory = ? AND BINARY experimentStatus = 'DONE - OLD' ;"
  sql += " SELECT count(*) from Experiments WHERE cores= ? AND GBMemory = ? AND BINARY experimentStatus = 'INTERRUPTED' ;"
  values = [CPUs, memory, CPUs, memory, CPUs, memory, CPUs, memory, CPUs, memory, CPUs, memory, CPUs, memory]
  connection.query({sql : sql,  values :
    values}, function(err, results){
    if(!err) {
      i = {
        'TotalExperiments' : results[0][0]['count(*)'],
        'Done' : results[1][0]['count(*)'],
        'Error' : results[2][0]['count(*)'],
        'NotStarted' : results[3][0]['count(*)'],
        'InProgress' : results[4][0]['count(*)'],
        'Removed' : results[5][0]['count(*)'],
        'Legacy' : results[6][0]['count(*)'],
        'Interrupted' : results[7][0]['count(*)'],
        'PercentCompleted' : ((+results[1][0]['count(*)'] + +results[2][0]['count(*)']) / (+results[0][0]['count(*)'] - +results[5][0]['count(*)'] )) * 100,
      }
      if ((i['Done'] + i['Error']) == (i['TotalExperiments'] - i['Removed'])){
        i['CellComplete'] = true
      }else{
        i['CellComplete'] = false
      }
      out = {
        success :true,
        timestamp: new Date().toLocaleString(),
        data : i,
        message: ""
      }
        res.json(out);
    }else{
      out = {
        success: false,
        timestamp : new Date().toLocaleString(),
        data: [],
        message: err
      }
      res.json(out)
    }
  })
})

app.get("/nextConfig", function(req, res){
  connection = createDBConnection(hostname, db, password, username)
  sql = "SELECT cores, GBMemory from Experiments where BINARY experimentStatus = 'NOT STARTED' ORDER BY cores, GBMemory ASC LIMIT 1;"
  connection.query(sql, function(err, results){
  if (!err){
    out = {
      success :true,
      timestamp: new Date().toLocaleString(),
      data : results,
      message: ""
    }
      res.json(out);
  }else{
    out = {
      success: false,
      timestamp : new Date().toLocaleString(),
      data: [],
      message: err
    }
    res.json(out)
  }
  })
})


app.listen(PORT);
