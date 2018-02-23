const PICTURES_ID_INDEX_NAME = "pictures_id_index";
exports.migrate = function(client, done) {
    const db = client.db;
    const pictures = db.collection('pictures');
    Promise.all([
        pictures.ensureIndex( { "id" : 1 }, { "name" : PICTURES_ID_INDEX_NAME, "unique" : true } ),
        db.createCollection("CVFeatureExtractors", { collation: { locale: 'en_US', strength: 2 } } )
    ]).then(() => done()).catch(done);
};

exports.rollback = function(client, done) {
    const db = client.db;
    const pictures = db.collection('pictures');
    Promise.all([
        pictures.dropIndex(PICTURES_ID_INDEX_NAME),
        db.dropCollection("CVFeatureExtractors")
    ]).then(() => done()).catch(done);
};
