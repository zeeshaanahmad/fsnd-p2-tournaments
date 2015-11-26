#!/usr/bin/env python
#
# tournament.py -- implementation of a Swiss-system tournament
#

import psycopg2


def connect():
    """Connect to the PostgreSQL database.  Returns a database connection."""
    # returns the connection object to tournament
    # database from PostgreSQL
    return psycopg2.connect("dbname=tournament")


def deleteMatches():
    """Remove all the match records from the database."""
    # gets connection to tournament database in conn object
    conn = connect()
    # gets the cursor to execute queries
    c = conn.cursor()
    # executes delete query to delete all records in MATCH table
    c.execute("DELETE FROM MATCH;")
    # commits the changes perform on MATCH table after delete statement executes
    conn.commit()
    # closes the connection to tournament database
    conn.close()


def deletePlayers():
    """Remove all the player records from the database."""
    # gets connection to tournament database in conn object
    conn = connect()
    # gets the cursor to execute queries
    c = conn.cursor()
    # executes delete query to delete all records in PLAYER table
    c.execute("DELETE FROM PLAYER;")
    # commits the changes perform on PLAYER table after delete statement executes
    conn.commit()
    # closes the connection to tournament database
    conn.close()


def countPlayers():
    """Returns the number of players currently registered."""
    # gets connection to tournament database in conn object
    conn = connect()
    # gets the cursor to execute queries
    c = conn.cursor()
    # executes select with count aggregate function query number of players
    # in PLAYER table
    c.execute("SELECT COUNT(*) FROM PLAYER;")
    # retreives the result in count variable
    count = c.fetchone() [0]
    # closes the connection to tournament database
    conn.close()
    # returns the number of players in PLAYER table
    return count


def registerPlayer(name):
    """Adds a player to the tournament database.

    The database assigns a unique serial id number for the player.  (This
    should be handled by your SQL database schema, not in your Python code.)

    Args:
      name: the player's full name (need not be unique).
    """
    # gets connection to tournament database in conn object
    conn = connect()
    # gets the cursor to execute queries
    c = conn.cursor()
    # executes insert query which takes the name variable passed in arguments
    # of this method and adds a new player record to PLAYER table where the
    # ID is generated automatically for new created record
    c.execute("INSERT INTO PLAYER VALUES (DEFAULT, %s)", (name,))
    # commits the changes performed on PLAYER table
    # after insert statement executes
    conn.commit()
    # closes the connection to tournament database
    conn.close()


def playerStandings():
    """Returns a list of the players and their win records, sorted by wins.

    The first entry in the list should be the player in first place, or a player
    tied for first place if there is currently a tie.

    Returns:
      A list of tuples, each of which contains (id, name, wins, matches):
        id: the player's unique id (assigned by the database)
        name: the player's full name (as registered)
        wins: the number of matches the player has won
        matches: the number of matches the player has played
    """
    # gets connection to tournament database in conn object
    conn = connect()
    # gets the cursor to execute queries
    c = conn.cursor()
    # executes select statement on STANDING view for getting results in
    # descending order of number of wins for each player
    c.execute("SELECT * FROM STANDING ORDER BY WINS DESC;")
    # results are stored in ps variable
    ps = c.fetchall()
    # closing the connection to tournament database
    conn.close()
    # returns the results receieved from tournament database
    return ps

# Changed the arguments of reportMatch to support drawn matches
def reportMatch(winner, loser, draw):
    """Records the outcome of a single match between two players.

    Args:
      winner:  the id number of the player who won
      loser:  the id number of the player who lost
    """
    # gets connection to tournament database in conn object
    conn = connect()
    # gets the cursor to execute queries
    c = conn.cursor()
    # sql insert query to add new MATCH record in the MATCH table with
    # passing winner or loser player id and true or false for draw
    # When there is draw, both winner and loser columns will have IDs of
    # both players which later on gets counted as 0.5 points for each player
    # while 1 for winner and 0 for loser
    query = "INSERT INTO MATCH (winner, loser, draw) VALUES (%s, %s, %s);"
    args = (winner, loser, draw)
    # executing insert query to add new Match information
    c.execute(query, args)
    # commits the changes performed on MATCH table after adding new match
    conn.commit()
    # closing connection to tournament database
    conn.close()


def swissPairings():
    """Returns a list of pairs of players for the next round of a match.

    Assuming that there are an even number of players registered, each player
    appears exactly once in the pairings.  Each player is paired with another
    player with an equal or nearly-equal win record, that is, a player adjacent
    to him or her in the standings.

    Returns:
      A list of tuples, each of which contains (id1, name1, id2, name2)
        id1: the first player's unique id
        name1: the first player's name
        id2: the second player's unique id
        name2: the second player's name
    """
    # retreives player standings i.e. id, player, wins, matches
    standings = playerStandings()
    # pairs for next round are stored in this array.
    next_round = []

    # iterates on the standings results. As the results are already in
    # descending order, the pairs can be made using adjacent players, hence the
    # loop is set to interval of 2 to skip to player for next pair
    # in every iteration.
    for i in range(0, len(standings), 2):
        # each iteration picks player attributes (id, name) of current row
        # and next row and adds in the next_round array.
        next_round.append((standings[i][0], standings[i][1], standings[i+1][0], standings[i+1][1]))
    # pairs for next round are returned from here.
    return next_round
