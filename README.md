# xSystems PostgreSQL Google Storage Restore

> Service to _**one-off**_ restore a PostgreSQL database backup from a Google Storage Bucket

## Usage

### Run

[Create a GCP service account][gcp-service-account-create] and [create a key for that service account][gcp-service-account-key].
Next, [assign the service account the role][gcp-bucket-level-policy-member] **Storage Admin** w.r.t. the Google Cloud Storage bucket. 

Create a [PostgreSQL password file][postgres-pgpass], matching your database's configuration AND environment variables mentioned later on.

> **NOTE:** Make sure that, on Unix systems, the permissions on both before mentioned credential files are set to `0400`. 
>           For example, to achieve this run: `chmod 0400 gcp-credentials.json .pgpass`

When running a container of this image you **MUST** mount both before mentioned credentials under `/run/secrets/` inside the container.
That is, the following files **MUST** be available inside the container:

  - `/run/secrets/gcp-credentials.json`
  - `/run/secrets/.pgpass`

This can either be achieved using Docker Volumes or Docker Secrets.

Also, when running a container of this image you **MUST** specify the environment variables `GCP_PROJECT`, `GCP_BUCKET`, `POSTGRES_DATABASE`.
Other environment variables are available, but are optional.

All available environment variables are:

| Environment Variable        | Default Value | Required  | Description                                                                                 |
| :-------------------------- | :------------ | :-------: | :------------------------------------------------------------------------------------------ |
| GCP_BUCKET                  |               |     ✔    | The Google Cloud Storage Bucket name                                                        |
| GCP_PROJECT                 |               |     ✔    | The Google Cloud _**Project ID**_ of the project the Google Cloud Storage Bucket is part of |
| POSTGRES_DATABASE           |               |     ✔    | The PostgreSQL database. _Should match the `.pgpass` file mentioned above_                  |
| POSTGRES_HOST               | 172.18.0.1    |           | The PostgreSQL hostname. _Should match the `.pgpass` file mentioned above_                  |
| POSTGRES_PORT               | 5432          |           | The PostgreSQL port. _Should match the `.pgpass` file mentioned above_                      |
| POSTGRES_USER               | postgres      |           | The PostgreSQL username. _Should match the `.pgpass` file mentioned above_                  |

> **NOTE:** A backup file with the name `${POSTGRES_DATABASE}.gz` is expected in the specified Google Storage Bucket called.

> **NOTE:** It is required that BOTH the backup AND database exist.

### Example

This image can be used as follows:

```sh
docker run  --tty \
            --interactive \
            --rm \
            --env GCP_PROJECT=<REPLACE_WITH_PROJECT_NAME> \
            --env GCP_BUCKET=<REPLACE_WITH_BUCKET_NAME> \
            --env POSTGRES_DATABASE=<REPLACE_WITH_DATABASE_NAME> \
            --volume `pwd`/gcp-credentials.json:/run/secrets/gcp-credentials.json \
            --volume `pwd`/.pgpass:/run/secrets/.pgpass \
            xsystems/postgres-gs-restore
```


## Build the Image

Run [build.sh](build.sh) to build an image of the current codebase state with tag `latest`.


## Release the Image

1. Set the `VERSION` environment variable to the version that needs to be released.
2. Optionally, set the `COMMIT` environment variable to the hash of the Git commit that needs to be released. It defaults to the latest commit.
3. Run [release.sh](release.sh).

Example release statement:

```sh
VERSION=1.3.42 ./release.sh
```


[gcp-service-account-create]: https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating "Creating a GCP service account"
[gcp-service-account-key]: https://cloud.google.com/iam/docs/creating-managing-service-account-keys#creating_service_account_keys "Creating a GCP service account key"
[gcp-bucket-level-policy-member]: https://cloud.google.com/storage/docs/access-control/using-iam-permissions#bucket-add "Adding a member to a bucket-level policy"
[postgres-pgpass]: https://www.postgresql.org/docs/9.3/libpq-pgpass.html "The PostgreSQL password file .pgpass"
