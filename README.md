
[Docker Compose](https://github.com/docker/compose) file to manage the build and deployment of [MTW-MeSH](https://github.com/filak/MTW-MeSH), an app developped for the National Medical Library([NML](https://nlk.cz/), Prague, Czech Republic) for the translation of MeSH vocabulary ([Medical Subject Headings](https://www.nlm.nih.gov/mesh/)).

This Compose file make uses of this [Jena Fuseki docker image](https://github.com/stain/jena-docker/tree/master/jena-fuseki).

# Installation

Install [Docker Desktop](https://www.docker.com/products/docker-desktop) for Windows and macOS.

Clone the repository:

```bash
git clone https://github.com/JulienBacquart/MTW-MeSH-Docker
```

 Move into the new directory :
```bash
 cd MTW-MeSH-Docker/
```

# Initial setup

These operations are only necessary before the first launch.   
All modified files are saved to volumes, so as long as the volumes are persisted (including moving to a new release, removing the containers etc.) it's not necessary to re-run these operations. 

## Edit the default configuration

### Edit the mtw-dist.ini file :

**Important values are marked with !**  
Modify the values for your personnal configuration, including `TARGET_YEAR`, `TARGET_LANG`, `TARGET_NS` etc.  

Make sure this line is uncommented :  
`SPARQL_HOST = http://jena_fuseki:3030/`

For more details, refer to [MTW-MeSH Wiki](https://github.com/filak/MTW-MeSH/wiki/Installation-on-Windows#mtw-binaries)

### Change the default password :

A default value is provided for the admin pass for both MTW and Jena Fuseki as a secret in the `admin_settings.txt` file.  
Make sure to change this value and not to reveal then content of this file (via git for example).

## Build the image
```bash
docker compose build
```

## Loading the MeSH datasets

For more details see: [Loading MeSH datasets](https://github.com/filak/MTW-MeSH/wiki/Loading-MeSH-datasets)

Copy the official annual RDF dataset and your RDF translation dataset to the `./mesh-data/` directory.

### Validate the datasets :

Make sure to validate your `mesh.nt.gz` and `mesh-trx_YYYY-MM-DD.nt.gz` file with `riot`.  

You can for example use the [Jena Docker image](https://github.com/stain/jena-docker/tree/master/jena) :
```bash
docker run --rm --volume /$(pwd)/mesh-data/:/rdf stain/jena riot --validate mesh.nt.gz mesh-trx_YYYY-MM-DD.nt.gz
```

---

A special service called `staging` is part of the Compose file to load the MeSH data into the triple store.  

**All the data already present in the Mesh dataset in Jena Fuseki will be lost.**

Type the following command:

```bash
docker compose run --rm staging
```

# Run MTW
```bash
docker compose up -d
```
MTW should be accessible on: http://127.0.0.1:55930/mtw/  
Jena fuseki on: http://127.0.0.1:3030/#/

# Credits

- Thanks to [filak](https://github.com/filak) for his work on the [MTW app](https://github.com/filak/MTW-MeSH), his assistance in deploying it and his help into writting this Docker Compose file.

- [JulienBacquart](https://github.com/JulienBacquart)

