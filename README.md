# pyodbcbase

This repo builds a docker image which is meant to be used by our containers that depend on pyodbc and Microsoft SQL server-related libraries and tools.

* See the [pyodbcbase Docker Hub repo](https://hub.docker.com/r/edence/pyodbcbase)
* See the [pyodbcbase GitHub repo](https://github.com/edencehealth/pyodbcbase)

The image includes a non-root UID and GID (65532 for both by default).
