package App::SD::Replica::oslccm::PullEncoder;
use Any::Moose;
extends 'App::SD::ForeignReplica::PullEncoder';

use Params::Validate qw(:all);
use Memoize;
use DateTime;

use App::SD::Util;

has sync_source => (
    isa => 'App::SD::Replica::oslccm',
    is  => 'rw',
);

my %PROP_MAP = %App::SD::Replica::oslccm::PROP_MAP;

sub ticket_id {
    my $self = shift;
    my $ticket = shift;
    #return $ticket->number;
}


=head2 find_matching_tickets QUERY

Returns an array of all tickets found that match your QUERY hash 

=cut

sub find_matching_tickets {
    my $self = shift;
    my %query = (@_);

    $self->sync_source->log("Searching for tickets");
    $self->sync_source->oslccm->get_oslc_resources;
       
}

sub translate_ticket_state{}


1;
