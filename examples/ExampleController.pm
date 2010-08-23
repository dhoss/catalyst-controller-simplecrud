package Int80::Controller::Quote;

use Moose;

BEGIN {
    extends 'Catalyst::Controller';
}

__PACKAGE__->config(
    # stash label for item, make sure you set this
    item_label => 'user',
    # add_form defaults to edit_form unless specified
    add_form => 'Int80::Form::User::Add',
    edit_form => 'Int80::Form::User::Edit',
    # class to perform crud operations on
    model_class => 'IDB::User',
    # templates to use for crud actions
    templates => {
        create => 'user/form.tt2',
        edit => 'user/form.tt2',
        list => 'user/list.tt2',
    }
);

# define the base action from which SimpleCRUD will chain off of
sub base :Chained('/') :PathPart('user') :CaptureArgs(0) {
    my ($self, $c) = @_;
}

# subclass SimpleCRUD
extends 'Catalyst::Controller::SimpleCRUD';

# use method modifiers to hook onto the actions in order to do other stuff 
after [qw/edit create/] => sub {
    my ($self, $c) = @_;
    $c->forward('list') if $c->req->method eq 'POST';
};

after 'delete' => sub {
    my ($self, $c) = @_;
    $c->forward('list');
};

__PACKAGE__->meta->make_immutable;
