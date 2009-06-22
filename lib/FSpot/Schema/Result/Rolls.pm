package FSpot::Schema::Result::Rolls;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("rolls");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "time",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-16 04:41:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7v8+ZHjZwEIJ0RqQqkt7YA


# You can replace this text with custom content, and it will be preserved on regeneration
1;

__END__

=head1 NAME

FSpot::Schema::Result::Rolls - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to FSpot::Schema::Result::Rolls version 0.1.

=head1 SYNOPSIS

   use FSpot::Schema::Result::Rolls;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.

=cut

