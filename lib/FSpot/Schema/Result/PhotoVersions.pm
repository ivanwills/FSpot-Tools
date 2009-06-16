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


# You can replace this text with custom content, and it will be preserved on regeneration
1;
