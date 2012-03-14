package App::SD::Replica::oslccm;
use Any::Moose;
extends qw/App::SD::ForeignReplica/;

use Params::Validate qw(:all);
use Memoize;
use Try::Tiny;

use URI;
use Net::OSLC::CM;
use Prophet::ChangeSet;

#use un client rest, ou alors un module special oslc

use constant scheme => 'oslccm';
use constant pull_encoder => 'App::SD::Replica::oslccm::PullEncoder';
use Prophet::ChangeSet;

has oslccm     => (isa => 'Net::OSLC::CM::Connection', is => 'rw');
has remote_url => (isa => 'Str', is => 'rw');
has query      => (isa => 'Maybe[Str]', is => 'rw');

sub BUILD {
    my $self = shift;

    #Use 'require' refer than 'use' to defer load
    try {
        require Net::OSLC::CM;
    } catch {
        warn $_ if $ENV{PROPHET_DEBUG};
        die "Net::OSLC::CM is required to sync via OSLC-CM protocole\n";
    };

    # $type and $query are empty
    my ($server, $type, $query) = $self->{url} =~ m/^oslccm:(.*?)$/
    or die "Can't parse OSLC server spec. Expected oslccm:http://example.com";

    my $uri = URI->new($server);

    $self->remote_url($uri->as_string);

    #authentication

    $self->oslccm(
        Net::OSLC::CM::connect(url => $self->remote_url)  
    );

    print 'test';
    #just testing
    #my $request = HTTP::Request->new(GET => "http://192.168.56.101:8282/bugz/provider?productId=1");
    #my $response = $self->oslccm->request($request);
    #print $response->as_string;
}

sub record_pushed_transactions {}

sub _uuid_url {
    my $self = shift;
    return $self->remote_url;
}

sub remote_uri_path_for_id {
    my $self = shift;
    my $id = shift;
    return "/issues/show".$id;
}


__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;
