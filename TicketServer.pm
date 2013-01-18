package TicketServer;

use Moose; # includes strict and warnings
use Carp;
use DBI;

# required => 1
has dsn => ( is => 'rw' );
has user => ( is => 'rw' );
has password => ( is => 'rw' );
has seq_table => ( is => 'rw' );

sub get_id {
    my $self = shift;

    my $dbh = DBI->connect($self->dsn, $self->user, $self->password) 
              || die "Could not connect to database: $DBI::errstr";

    my $dbname;
    if ($self->dsn =~ m{DBI : [^:]+ : (?:dbname=) (\w+)}ix) {
        $dbname = $1;
    } else {
        Carp::croak("Couldn't get database name from DSN $self->dsn");
    }

    my $sth = $dbh->prepare("REPLACE INTO " . $self->seq_table . "(stub) VALUES ('a')");
    my $rv = $sth->execute();
    if (!$rv) {
        Carp::croak ("Couldn't get a new ID from $self->seq_table :$!");
    } 

    my $new_id = $dbh->last_insert_id(undef, $dbname, $self->seq_table, 'id');

    $dbh->disconnect();

    return $new_id;
}

__PACKAGE__->meta->make_immutable;

1;
