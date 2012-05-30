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
    required => 1
);

my %PROP_MAP = %App::SD::Replica::oslccm::PROP_MAP;

=head2 find_matching_tickets QUERY

Returns an array of all tickets found that match your QUERY hash 

=cut

sub find_matching_tickets {
    my $self = shift;
    my %query = (@_);

    $self->sync_source->log("Searching for tickets");

    # Getting a list of Net::OSLC::CM::Ticket objects
    my @results = @{$self->sync_source->oslccm->get_oslc_resources};
    return \@results; 
}

sub ticket_id {
    my $self = shift;
    my $ticket = shift;
    return $ticket->identifier;
}

sub find_matching_transactions {
    my $self = shift;
    my %args = validate(@_, {ticket => 1, starting_transaction => 1});

    my @raw_txns = $args{ticket}; #@{ $args{ticket}->{identifier} };
    my @txns = ();
   
   
    #when ticket hasn't been created, add it to the beginning of the list of 
    #transactions
    
    

    for my $txn ( sort { $a->{identifier} <=> $b->{identifier} } @raw_txns ){
      my $txn_date = $txn->{modified}->epoch;

      next if $txn_date < ( $args{'strating_transaction'} || 0 );

      next if (
        $self->sync_source->foreign_transaction_originated_locally(
          $txn_date, $args{'ticket'}->{identifier}
        )
      );
    
       push @txns, {
           timestamp => $txn->{created_at},
           serial => $txn->{identifier},
           object => $txn,
       };
    }
  
   my @ticket_created = $args{ticket}->{created};
   
   if ($ticket_created[0]->epoch >= $args{'starting_transaction'} || 0 ){
     push @txns,
       {
         timestamp => $ticket_created[0],
         serial => 0,
         object => $args{ticket},
       };
   }
  
   $self->sync_source->log_debug('Done looking at pulled txns');
    print "end \n";
    return \@txns;
}


sub translate_ticket_state{
  print "translate_ticket_state \n";
    my $self          = shift;
    my $ticket        = shift;
    my $transactions  = shift;

    print $ticket->created . "\n";
   

    my $final_state = {
        $self->sync_source->uuid . '-id' => $ticket->identifier,
        status      => $ticket->status,
        summary     => $ticket->subject,
        description => $ticket->description,
        #priority   => $ticket->priority,
        created     => $ticket->created->epoch,
        creator     => $ticket->contributor
    };
    my $initial_state = {%$final_state};
    
    for my $txn ( sort { $b->{'serial'} <=> $a->{'serial'} } @$transactions ) {
        $txn->{post_state} = {%$final_state};
        if ($txn->{serial} == 0){
            $txn->{pre_state} = {};
            last;
        }
        
        #my $property_changes = $txn->{object}->property_changes;
        #while (my ($name, $changes) = each(%$property_changes)) {
        #    $initial_state->{$name} = $changes->{from};
        #}

        $txn->{pre_state} = {%$initial_state};
    }

    print "return from translate_ticket_state \n"; 
    return $initial_state, $final_state;
}

sub transcode_one_txn {
    print "transcode_one_txn \n";
    my $self = shift;
    my $txn_wrapper = shift;
    my $older_ticket_state = shift;
    my $newer_ticket_state = shift;

    my $txn = $txn_wrapper->{object};
    
    if ($txn_wrapper->{serial} == 0){
        return $self->transcode_create_txn($txn_wrapper, $older_ticket_state, $newer_ticket_state);
    }
    
    my $ticket_id   = $newer_ticket_state->{ $self->sync_source->uuid . '-id' };
    my $ticket_uuid = $self->sync_source->uuid_for_remote_id($ticket_id);
    my $creator     = $newer_ticket_state->{creator};
    my $created     = $newer_ticket_state->{created};

    my $changeset = Prophet::ChangeSet->new({
        original_source_uuid => $ticket_uuid,
        original_sequence_no => $txn->identifier,
        creator              => $creator,
        created              => $created,
    });

    my $change = Prophet::Change->new({
        record_type => 'ticket',
        record_uuid => $ticket_uuid,
        change_type => 'update_file',
    });

    for my $prop ( keys %{ $txn_wrapper->{post_state} } ) {
        my $new = $txn_wrapper->{post_state}->{$prop};
        my $old = $txn_wrapper->{pre_state}->{$prop};

        next unless defined($new) && defined($old);

        $change->add_prop_change(
            name => $prop,
            new  => $new,
            old  => $old,
        ) unless $new eq $old;
    }

    $changeset->add_change({ change => $change });

    #no comment in ChangeRequest class yet
    #$self->_include_change_comment($changeset, $ticket_uuid, $txn);
    print "return from transcode_one_txn \n";
    return $changeset;
}

sub _include_change_comment {
    my $self        = shift;
    my $changeset   = shift;
    my $ticket_uuid = shift;
    my $txn         = shift;

    my $comment = $self->new_comment_creation_change();

    #my $content = $txn->{description} || "";
    my $content = $txn->{comment} || "";

    if ( $content !~ /^\s*$/s ) {
        $comment->add_prop_change(
            name => 'created',
            new  => $txn->date->ymd . ' ' . $txn->date->hms,
        );
        $comment->add_prop_change(
            name => 'creator',
            new => $self->resolve_user_id_to(email_address => $txn->{creator})
        );
        $comment->add_prop_change( name => 'content', new => $content );
        $comment->add_prop_change(
            name => 'content_type',
            new  => 'text/plain',
        );
        $comment->add_prop_change( name => 'ticket', new => $ticket_uuid, );

        $changeset->add_change( { change => $comment } );
    }
}

sub transcode_create_txn {
    my $self        = shift;
    my $txn         = shift;
    my $create_data = shift;
    my $final_data  = shift;

    my $ticket_id   = $final_data->{ $self->sync_source->uuid . '-id' };
    my $ticket_uuid = $self->sync_source->uuid_for_remote_id($ticket_id);
    my $creator     = 'xxx@example.com';
    my $created     = $final_data->{created};

    my $changeset = Prophet::ChangeSet->new({
        original_source_uuid => $ticket_uuid,
        original_sequence_no => 0,
        creator              => $creator,
        created              => $created,
    });

    my $change = Prophet::Change->new({
        record_type => 'ticket',
        record_uuid => $ticket_uuid,
        change_type => 'add_file',
    });

    while ( my ($name, $value) = each %{ $txn->{post_state} }) {
        $change->add_prop_change(
            name => $name,
            new => $value
        )
    }

    $changeset->add_change({ change => $change });

    # for my $att ( @{ $txn->{object}->attachments } ) {
    #     $self->_recode_attachment_create(
    #         ticket_uuid => $ticket_uuid,
    #         txn         => $txn->{object},
    #         changeset   => $changeset,
    #         attachment  => $att,
    #     );
    # }

    return $changeset;
}

sub translate_prop_status {}

sub resolve_user_id_to {
    my $self = shift;
    my $to   = shift;
    my $id   = shift;
    return $id;
}

__PACKAGE__->meta->make_immutable;
no Any::Moose;
1;
