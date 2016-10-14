amazon = require('amazon-product-api');

var client = amazon.createClient({
  awsId: "AKIAISWZLHXLRWBD46NQ",
  awsSecret: "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",
});

client.itemSearch({
  director: 'Quentin Tarantino',
  actor: 'Samuel L. Jackson',
  searchIndex: 'DVD',
  audienceRating: 'R',
  responseGroup: 'ItemAttributes,Offers,Images'
}).then(function(results){
  console.log(results);
}).catch(function(err){
  console.log(err['Error'][0]);
});
