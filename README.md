# wait-for-db

Wait for the db to be up and/or initialized using knex. It exits successfully as soon as the db
is in the desired state. If the db remains offline after the maximum tries the scripts exits
with an error.

## Usage
`wait-for-db [-d] [-v] [-q] [-i] [-t tries] [-s seconds]`
- `-d` debug
- `-v` verbose
- `-q` quiet operation, turn debug and verbose off
- `-i` wait until db is initialized
- `-t` how many tries are done
- `-s` how many seconds to wait between tries

