#!/usr/bin/env perl

use warnings;
use strict;
use TicketServer;

my $host = 'localhost';
my $port = 3306;
my $dbname = 'tickets';
my $dsn = "DBI:mysql:dbname=$dbname;host=$host;port=$port";
my $user = 'root';
my $pwd = 'mysql';
my $seq_table = 'Tickets64';

my $ticket_server = TicketServer->new(dsn=>$dsn, user=>$user, pwd=>$pwd, 
                                      seq_table=>$seq_table);
my $id = $ticket_server->get_id();
print "ID: $id\n";
