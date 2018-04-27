exports.migrate = function(client, done) {
    const db = client.db;

    const onlineJobsP = db.createCollection("onlineJobs", { collation: { locale: 'en_US', strength: 2 } } );

    const models = db.collection('CVModels');
    const albums = db.collection('albums');

    const modelsUpdatesP = models.find().toArray().then((oldModels) => {
        const inputIds = oldModels.map((model) => model.input);
        return albums.find( { "id" : { $in : inputIds } } ).toArray().then((inputAlbums) => {
            return Promise.all(oldModels.map((oldModel) => {
                const album = inputAlbums.find((inputAlbum) => inputAlbum.id === oldModel.input);
                return models.updateOne(
                    { "id" : oldModel.id },
                    { $set : { "labelMode" : album.labelMode } }
                );
            }));
        });
    });

    Promise.all([onlineJobsP, modelsUpdatesP]).then(() => done()).catch(done);
};

exports.rollback = function(client, done) {
    const db = client.db;
    const models = db.collection('CVModels');
    models.updateMany( {}, { $unset : { "labelMode" : "" } } ).then(() => done()).catch(done);
};