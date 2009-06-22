package FSpot::Schema::Result::PhotoVersions;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("photo_versions");
__PACKAGE__->add_columns(
  "photo_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "version_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "name",
  {
    data_type => "STRING",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "uri",
  {
    data_type => "STRING",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "md5_sum",
  {
    data_type => "STRING",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "protected",
  {
    data_type => "BOOLEAN",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->add_unique_constraint("photo_id_version_id_unique", ["photo_id", "version_id"]);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-16 04:41:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:i3yCLa42l2KMXhibh3hCyw

__PACKAGE__->set_primary_key('photo_id', 'version_id');

__PACKAGE__->belongs_to( photo_id => 'FSpot::Schema::Result::Photos' );
1;

__END__

=head1 NAME

FSpot::Schema::Result::PhotoVersions - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to FSpot::Schema::Result::PhotoVersions version 0.1.

=head1 SYNOPSIS

   use FSpot::Schema::Result::PhotoVersions;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.

=cut

