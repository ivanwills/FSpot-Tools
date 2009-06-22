package FSpot::Schema::Result::Meta;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("meta");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "name",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "data",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("name_unique", ["name"]);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-16 04:41:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZyAdSxJWeIh7DxKqDHxaxw


# You can replace this text with custom content, and it will be preserved on regeneration
1;

__END__

=head1 NAME

FSpot::Schema::Result::Meta - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to FSpot::Schema::Result::Meta version 0.1.

=head1 SYNOPSIS

   use FSpot::Schema::Result::Meta;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.

=cut

