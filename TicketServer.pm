package TicketServer;

use Moose; # includes strict and warnings
use Carp;
use DBI;

has [ 'dsn', 'user', 'seq_table' ] => ( is => 'ro', required => 1 );
has 'pwd' => ( is => 'ro' );
has dbh => ( is => 'ro',
             writer => '_set_dbh' );
has dbname => ( is => 'ro', 
                lazy => 1,
                writer => '_set_dbname',
                builder => '_build_dbname' );

sub _build_dbname {
    my $self = shift;
    if ($self->dsn =~ m{DBI : [^:]+ : (?:dbname=) (\w+)}ix) {
        $self->_set_dbname($1);
    } else {
        Carp::croak("Couldn't get the database name from DSN: " . $self->dsn);
    }
}

sub get_dbh {
    my $self = shift;

    if ( ! ($self->dbh and ref $self->dbh and $self->dbh->ping()) ){
        # Connect to the database if dbh has not been created yet or 
        # is not active
        my $dbh = DBI->connect($self->dsn, $self->user, $self->pwd)
              || Carp::croak("Could not connect to database: $DBI::errstr");
        $self->_set_dbh($dbh);
    }

    return $self->dbh;
}

sub get_id {
    my $self = shift;

    my $dbh = $self->get_dbh();

    my $sth = $dbh->prepare("REPLACE INTO " . $self->seq_table . "(stub) VALUES ('a')");
    $sth->execute()
        or Carp::croak ("Couldn't get a new ID from $self->seq_table: $DBI::errstr");

    my $new_id = $dbh->last_insert_id(undef, $self->dbname, $self->seq_table, 'id');

    return $new_id;
}

__PACKAGE__->meta->make_immutable;

1;
