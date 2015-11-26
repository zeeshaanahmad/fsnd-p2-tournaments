# Tournaments
## Description
This project works with PostgreSQL database to setup a database of tournament and generate Swiss-Pairings for players using python.

## Whats included?
Tournament Project
- tournament.sql
- tournament.py
- tournament_test.py

### tournament.sql
This sql file sets up a tournament database schema with tables like PLAYER, MATCH and views like MATCHES_PLAYED, PLAYER_WINS, TIES, STANDING.

### tournament.py
This python file contains methods to connect, read, add, delete players and matches information and to generate player standings and swiss-pairings.  

### tournament_test.py
This python file has scripts to test the methods implemented in tournament.py file which verifies whether all the methods are working and passing the tests.

## How to setup environment?
Follow the guidelines provided in the [project description][1] to set up the vagrant vm and clone the [fullstack-nanodegree-vm][2] repository. Clone [this][3] repository to `<path to your local fullstack-nanodegree-vm folder>/vagrant/tournament` folder. It will replace the default files `tournament.sql`, `tournament.py` and `tournament_test.py` with files from this repository.

## How to execute tests?
After following the guidelines in project description and setting up the environment and vagrant vm using `vagrant up` followed by `vagrant ssh`

1. Navigate to tournament project folder `cd /vagrant/tournament`
2. Write `psql` to go to PostgreSQL
3. Run `\i tournament.sql` to create and import the tournament database schema.
4. Once the database has been setup, quit the PostgreSQL interface using `\q`
5. Execute the following command  `python tournament_test.py` to test the methods implemented in tournament.py
6. Test results will be printed on the screen.

[1]: https://docs.google.com/document/d/16IgOm4XprTaKxAa8w02y028oBECOoB1EI1ReddADEeY/pub?embedded=true
[2]: https://github.com/udacity/fullstack-nanodegree-vm
[3]: https://github.com/zeeshaanahmad/fsnd-p2-tournaments
