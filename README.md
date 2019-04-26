# Kong Interpolated

Custom Kong to accept variable interpolation on declaratives files. Also, allow multiple YAMLs.

## Getting Started

Just build it or use a pre-built image leandrocarneiro/kong:1.1.2-centos-i

## Using with a single file

With Kong, you can set the YAML declarative configuration file using the variable **KONG_DECLARATIVE_CONFIG**, now it supports environment variable interpolation.

### Configure

**example.yaml**
```
---
_format_version: '1.1'
services:
- name: httpbin
  url: http://httpbin.org/anything/secret/${MY_SECRET_VAR}/it-works

routes:
- name: httpbin
  service: httpbin
  paths:
  - "/"
```

Remember to set the environment variable to be interpolated: **MY_SECRET_VAR**

```
docker run -d --rm \
  -p 8000:8000 \
  -p 8001:8001 \
  -e MY_SECRET_VAR=SuperSecretValue \
  -e KONG_DECLARATIVE_CONFIG="/example.yaml" \
  -v ${PWD}/examples/single_file/example.yaml:/example.yaml \
  leandrocarneiro/kong:1.1.2-centos-i
```

### Test it

`http -b GET localhost:8000/ | grep SuperSecretValue`

```
  "url": "https://localhost/anything/secret/SuperSecretValue/it-works"
```

## Using with multiple files

You can set a directory with "n" YAML files using the variable **DECLARATIVES_DIR**, they will be merged into one file and the variables will be interpolated.
Note1: file extensions must be `.yml` or `.yaml`

### Configure

At least: must have a YAML file with content `_format_version: '1.1'`

File structure:
```
examples/
└── multiple_files
    ├── must_have.yaml
    ├── routes
    │   └── routes-for-httpbin.yaml
    ├── plugins
    │   └── global_plugins.yaml
    └── services
        └── httpbin.yaml
```

Must set environment variable **DECLARATIVES_DIR**

```
docker run -d --rm \
  -p 8000:8000 \
  -p 8001:8001 \
  -e MY_SECRET_VAR=SuperSecretValue \
  -e DECLARATIVES_DIR="/yamls" \
  -v ${PWD}/examples/multiple_files:/yamls \
  leandrocarneiro/kong:1.1.2-centos-i
```

### Test it

`http -b GET localhost:8000/ | grep SuperSecretValue`

```
  "url": "https://localhost/anything/multiple-files/SuperSecretValue/wow"
```

## Known issues

Need to edit `/entrypoint.sh` to work with secrets.