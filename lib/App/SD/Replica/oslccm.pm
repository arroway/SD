package App::SD::Replica::oslccm;
use Any::Moose;
extends qw/App::SD::ForeignReplica/;

use Params::Validate qw(:all);
use Memoize;
use Try::Tiny;

use URI;
use Net::OSLC::CM;
use Prophet::ChangeSet;

use constant scheme => 'oslccm';
use constant pull_encoder => 'App::SD::Replica::oslccm::PullEncoder';
use Prophet::ChangeSet;

has oslccm     => (isa => 'Net::OSLC::CM', is => 'rw');
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
    my ($username, $password);
    if (my $auth = $uri->userinfo){
      ($username, $password) = split /:/, $auth, 2;
      $uri->userinfo(undef);
    }

    $self->remote_url($uri->as_string);

    #authentication
    ($username, $password) 
      = $self->prompt_for_login(
        uri      => $uri,
        username => $username,
      ) unless $password;

    $self->oslccm(
        Net::OSLC::CM->new(
          url      => $self->remote_url,
          username => $username,
          password => $password 
    ));

 }

sub record_pushed_transactions {}

sub _uuid_url {
    my $self = shift;
    return $self->remote_url;
}

sub remote_uri_path_for_id {
    my $self = shift;
    my $identifier = shift;
    return "/changerequest/".$identifier;
}


__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;
