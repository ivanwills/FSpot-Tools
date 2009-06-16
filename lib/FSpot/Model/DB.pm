package FSpot::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'FSpot::Schema',
    connect_info => [
        'dbi:SQLite:/home/ivan/.gnome2/f-spot/photos.db',
        
    ],
);

=head1 NAME

FSpot::Model::DB - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<FSpot>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<FSpot::Schema>

=head1 AUTHOR

Ivan Wills,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
