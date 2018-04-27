exports.migrate = function(client, done) {
    const db = client.db;
    Promise.all([
        db.createCollection("datasets", { collation: { locale: 'en_US', strength: 2 } } ),
        db.createCollection("flows", { collation: { locale: 'en_US', strength: 2 } } ),
        db.createCollection("modelRefs", { collation: { locale: 'en_US', strength: 2 } } ),
        db.createCollection("projects", { collation: { locale: 'en_US', strength: 2 } } ),
        db.createCollection("replays", { collation: { locale: 'en_US', strength: 2 } } ),
        db.createCollection("CVModels", { collation: { locale: 'en_US', strength: 2 } } ),
        db.createCollection("CVPredictions", { collation: { locale: 'en_US', strength: 2 } } ),
        db.createCollection("albums", { collation: { locale: 'en_US', strength: 2 } } ),
        db.createCollection("predictions", { collation: { locale: 'en_US', strength: 2 } } ),
        db.createCollection("pictures", { collation: { locale: 'en_US', strength: 2 } } )
    ]).then(() => done()).catch((err) => done(err));
};

exports.rollback = function(client, done) {
    const db = client.db;
    Promise.all([
        db.dropCollection("datasets"),
        db.dropCollection("flows"),
        db.dropCollection("modelRefs"),
        db.dropCollection("projects"),
        db.dropCollection("replays"),
        db.dropCollection("CVModels"),
        db.dropCollection("CVPredictions"),
        db.dropCollection("albums"),
        db.dropCollection("predictions"),
        db.dropCollection("pictures")
    ]).then(() => done()).catch((err) => done(err));
};
