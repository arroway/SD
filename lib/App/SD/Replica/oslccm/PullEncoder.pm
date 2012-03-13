package App::SD::Replica::oslccm::PullEncoder;
use Any::Moose;
extends 'App::SD::ForeignReplica::PullEncoder';

use Params::Validate qw(:all);
use Memoize;
use DateTime;

use App::SD::Util;

#use HTTP::Common::Request;

has sync_source => (
    isa => 'App::SD::Replica::oslccm',
    is  => 'rw',
);

my %PROP_MAP = %App::SD::Replica::oslccm::PROP_MAP;

sub ticket_id {
    my $self = shift;
    my $ticket = shift;
    return $ticket->number;
}


=head2 find_matching_tickets QUERY

Returns an array of all tickets found that match your QUERY hash 

=cut

sub find_matching_tickets {
    my $self = shift;
    my %query = (@_);

    #search query
    #return results

#    my $last_changeset_seen_dt = $self->_only_pull_tickets_modified_after()
#      || DateTime->from_epoch(epoch => 0);
#    $self->sync_source->log("Searching for tickets");
#   
#    my $issue = $self->sync_source->oslccm->issue;
#    my @updated = grep {
#      App::SD::Util::string_to_datetime($_->{updated_at}) > $last_changeset_seen_dt }
#      ( @{$issue->list('open')}, @{$issue->list('closed')});  
#    return \@updated;
       
}

sub translate_ticket_state{}


1;
