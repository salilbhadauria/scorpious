exports.migrate = function(client, done) {
    var db = client.db;
    db.createCollection("datasets", { collation: { locale: 'en_US', strength: 2 } } )
    db.createCollection("flows", { collation: { locale: 'en_US', strength: 2 } } )
    db.createCollection("modelRefs", { collation: { locale: 'en_US', strength: 2 } } )
    db.createCollection("projects", { collation: { locale: 'en_US', strength: 2 } } )
    db.createCollection("replays", { collation: { locale: 'en_US', strength: 2 } } )
    db.createCollection("CVModels", { collation: { locale: 'en_US', strength: 2 } } )
    db.createCollection("CVPredictions", { collation: { locale: 'en_US', strength: 2 } } )
    db.createCollection("albums", { collation: { locale: 'en_US', strength: 2 } } )
    db.createCollection("predictions", { collation: { locale: 'en_US', strength: 2 } } )
    db.createCollection("pictures", { collation: { locale: 'en_US', strength: 2 } } )
    done();
};