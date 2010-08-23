package Catalyst::Controller::SimpleCRUD;

use Moose;
use Carp;
use namespace::autoclean;

BEGIN {
    extends 'Catalyst::Controller';
}

sub item :Chained('base') :PathPart('') :CaptureArgs(1) {
    my ($self, $c, $item_id) = @_;

    my $item = $c->model( $self->config->{model_class} )->find($item_id)
        or return $c->error("Invalid item ID");

    $c->stash( $self->config->{item_label} => $item );
}

sub create :Chained('base') :PathPart('create') :Args(0) {
    my ($self, $c) = @_;

    # set add_form to edit_form unless defined
    $self->config->{add_form} ||= $self->config->{edit_form};
    # loads the form class
    Class::MOP::load_class($self->config->{add_form}) or croak 'Failed to load add form class';
    my $form = $self->config->{add_form}->new;

    $c->stash( template => $self->config->{templates}->{create}, form => $form );

    if ($c->req->method eq 'POST') {
        my $row = $c->model( $self->config->{model_class} )->new_result({});
        return unless $form->process( item => $row, params => $c->req->parameters );
    }
}

sub edit :Chained('item') :PathPart('edit') :Args(0) {
    my ($self, $c) = @_;
    
    # loads the form class
    Class::MOP::load_class($self->config->{edit_form}) or croak 'Failed to load edit form class';
    my $form = $self->config->{edit_form}->new;
    
    $c->stash( template => $self->config->{templates}->{edit}, form => $form );
    
    return unless $form->process( item => $c->stash->{$self->config->{item_label}}, params => $c->req->parameters );
}

sub list :Chained('base') :PathPart('list') :Args(0) {
    my ($self, $c) = @_;
    
    my @items = $c->model( $self->config->{model_class} )->all;
    
    # plural item_label for stash
    $c->stash( $self->config->{item_label}.'s' => \@items, template => $self->config->{templates}->{list} );
}

sub delete :Chained('item') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;

    my $item = $c->stash->{$self->config->{item_label}};
    $item->delete;
}

__PACKAGE__->meta->make_immutable;

# TODO: write some docs
