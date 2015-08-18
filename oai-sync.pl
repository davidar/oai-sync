#!/usr/bin/perl 

eval 'exec /usr/bin/perl  -S $0 ${1+"$@"}'
    if 0; # not running under some shell

=head1 NAME

.

=head1 SYNOPSIS

.

=head1 DESCRIPTION

.

=head1 AUTHORS

=over 4 

=item * Ed Summers <ehs@pobox.com>, David Roberts

=back

=cut

use strict;
use Getopt::Long;
use Net::OAI::Harvester;
use Pod::Usage;

my ( $url, $dir, $metadataPrefix, $from, $until, $set, $debug, $token ); 

GetOptions(
    'baseURL:s'		=> \$url,
    'dumpDir:s' => \$dir,
    'metadataPrefix:s'	=> \$metadataPrefix,
    'from:s'		=> \$from,
    'until:s'		=> \$until,
    'set:s'		=> \$set,
    'debug!'		=> \$debug,
    'resumptionToken:s' => \$token,
);

if ( !$metadataPrefix ) { 
    print STDERR "no --metadataPrefix specified so defaulting to oai_dc\n";
    $metadataPrefix = 'oai_dc';
}

if ( !$url or !$metadataPrefix ) { 
    pod2usage( { -verbose => 0 } );
}

my $harvester = Net::OAI::Harvester->new( baseURL => $url, dumpDir => $dir );
$Net::OAI::Harvester::DEBUG = 1 if $debug;

my %opts = ( 'metadataPrefix'	=> $metadataPrefix );
$opts{ 'from' } = $from if $from;
$opts{ 'until' } = $until if $until;
$opts{ 'set' } = $set if $set;

my $records;
if ( $token ) { 
    $opts{ resumptionToken } = $token;
    print STDERR "using resumption token: ",$token,"\n";
    $records = $harvester->listRecords( 
        resumptionToken => $token
    );
} else {
    $records = $harvester->listRecords( %opts );
}
my $finished = 0;
my $resumptionToken;
my $retryAfter = 60;

while ( ! $finished ) { 

    if ( $records->errorCode() ) { 
        print STDERR "error code: ",$records->errorCode(),"\n";
        print STDERR "error string: ",$records->errorString(),"\n";
        if ( $records->errorCode() == 503 ) {
            $retryAfter = $records->HTTPError()->header("Retry-After");
            print STDERR "Retry-After: ",$retryAfter,"\n";
        }

        sleep($retryAfter);
        print STDERR "continuing...\n";

        if ( $resumptionToken ) { 
            $records = $harvester->listRecords(
                resumptionToken => $resumptionToken->token()
            );
        } else { 
            $records = $harvester->listRecords( %opts );
        }

        redo;
    }

    while ( my $r = $records->next() ) { 
        print $r->header()->identifier(),"\n";
        #print $r->metadata()->asString(),"\n\n";
    }

    $resumptionToken = $records->resumptionToken();
    if ( $resumptionToken ) { 
        $opts{ resumptionToken } = $resumptionToken->token();
        print STDERR "using resumption token: ",$resumptionToken->token(),"\n";
        $records = $harvester->listRecords( 
            resumptionToken => $resumptionToken->token()
        );
    } else { 
        $finished = 1;
    }

}

