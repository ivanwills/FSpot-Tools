package FSpot;

# Created on: 2009-06-17 09:30:10
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use version;
use Carp qw/cluck/;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use Config::General;
use FSpot::Schema;
use FindBin qw/$Bin/;
use Path::Class;
use DateTime;
use File::Copy qw/copy move/;
use Digest::MD5 qw/md5_base64/;

our $VERSION     = version->new('0.0.1');
our @EXPORT_OK   = qw//;
our %EXPORT_TAGS = ();

has config => (
	is      => 'rw',
	#isa     => 'Config::General',
);

has config_file => (
	is      => 'rw',
	#isa     => 'Path::Class::File',
	builder => '_build_config_file',
	trigger => \&_build_config,
);

has _schema => (
	is  => 'rw',
	isa => 'FSpot::Schema',
);

has backed_up => (
	is  => 'rw',
	isa => 'String',
);

has roll_id => (
	is  => 'rw',
	isa => 'Int',
);

sub _build_config {
	my ($self, $file) = @_;

	if (!defined $file) {
		cluck "no config file yet\n";
	}
	elsif (-e $file) {
		my $cfg    = Config::General->new($file);
		$self->config({ $cfg->getall });

		$self->config->{connect_info} ||= "dbi:SQLite:$ENV{HOME}/.gnome2/f-spot/photos.db";
	}
	else {
		$self->config({ connect_info => "dbi:SQLite:$ENV{HOME}/.gnome2/f-spot/photos.db" });
	}

	return;
}

sub _build_config_file {
	my $self = shift;

	return if defined $self->config_file;

	$self->config_file(
		-f "$ENV{HOME}/.fspot-tools.conf" ? file "$ENV{HOME}/.fspot-tools.conf"
		: "$Bin/../fspot-tools.conf"      ? file "$Bin/../fspot-tools.conf"
		:                                   file './fspot-tools.conf'
	);

	$self->_build_config($self->config_file);

	return;
}

sub schema {
	my $self = shift;

	return $self->_schema if $self->_schema;

	my $schema   = FSpot::Schema->connect( $self->config->{connect_info} );

	return $self->_schema($schema);
}

sub backup_db {
	my ($self) = @_;

	return if $self->backed_up;

	my $db = $self->config->{connect_info};
	$db =~ s{^dbi:SQLite:}{}xms;

	die "Could not find the database to backup!\n" if !-f $db;

	my $date = DateTime->now( time_zone => "Australia/Sydney" );

	copy $db, "$db.$date";

	die "Could not create the backup!\n" if !-f "$db.$date";

	$self->backed_up("$db.$date");

	return $date;
}

sub restore_db {
	my ($self, $date) = @_;

	my $db = $self->config->{connect_info};
	$db =~ s{^dbi:SQLite:}{}xms;

	my $now = DateTime->now( time_zone => "Australia/Sydney" );

	if ( $date ) {
		die "No database $db.$date\n" if !-f "$db.$date";

		move $db, "$db.$now";
		move "$db.$date", $db;
	}
	elsif ( $self->backed_up && -f $self->backed_up ) {
		move $db, "$db.$now";
		move $self->backed_up, $db;
	}
	else {
		die "No database to restore!\n";
	}

	return;
}

sub add_roll {
	my ($self, $time) = @_;

	my $schema   = $self->schema;
	my $rolls    = $schema->resultset('Rolls');
	my $roll_id  = $rolls->max('id') + 1;
	$time ||= time;

	$rolls->create({ id => $roll_id, time => $time })->insert();

	return $self->roll_id($roll_id);
}

sub add_photo {
	my ($self, $file) = @_;

	$file = file($file)->absolute;

	my $schema   = $self->schema;
	my $photos   = $schema->resultset('Photos');
	my $photo_id = $photos->max('id') + 1;
	# need to work out how F-Spot does this
	#my $md5      = md5_base64($file->slurp);

	my $row = {
		id                 => $photo_id,
		time               => $file->stat->mtime,
		uri                => 'file://' . $file,
		description        => '',
		roll_id            => $self->roll_id,
		default_version_id => 1,
		rating             => 0,
		md5_sum            => '', #$md5,
	};

	$photos->create($row)->insert();

	$schema->resultset('PhotoVersions')->create({
		photo_id => $photo_id,
		version_id => 1,
		name       => 'Original',
		uri        => 'file://' . $file,
		md5_sum    => '', #$md5,
		protected  => 1,
	})->insert();

	# TODO Find any tags and add this photo to them

	return $photo_id;
}

sub add_photo_version {
	my ($self, $file, $photo_id, $name) = @_;

	$file   = file($file)->absolute;
	$name ||= 'Modified';

	my $schema   = $self->schema;
	my $versions   = $schema->resultset('PhotoVersions');
	my $version_id = $versions->max('id') + 1;
	# need to work out how F-Spot does this
	#my $md5      = md5_base64($file->slurp);

	my $row = {
		photo_id    => $photo_id,
		version_id  => $version_id,
		name        => $name,
		uri         => 'file://' . $file,
		md5_sum     => '', #$md5,
		protected   => 1,
	};

	$versions->create($row)->insert();

	return $version_id;
}

sub add_tag {
	my ($self, $tag, $category_id, $is_category) = @_;

	my $schema = $self->schema;
	my $tags   = $schema->resultset('Tags');

	# check that the tag desn't already exist
	my $check = $tags->search({ name => $tag });
	if ( $check->count ) {
		return $check->first->id;
	}

	my $tag_id = $tags->max('id') + 1;

	if ( !defined $category_id ) {
		my $import = $tags->search({ name => 'Import Tags' });
		$category_id = $import->first && $import->first->id ? $import->first->id : $self->add_tag('Import Tags', 0, 1);
	}
	$is_category ||= 0;

	$tags->create({
		id            => $tag_id,
		name          => $tag,
		category_id   => $category_id,
		is_category   => $is_category,
		sort_priority => 0,
		icon          => 'stock_icon:f-spot-imported-xmp-tags.png',
	})->insert();

	return $tag_id;
}

sub add_tag_photo {
	my ($self, $tag_id, $photo_id) = @_;

	my $tags = $self->schema->resultset('PhotoTags');

	$tags->create({ tag_id => $tag_id, photo_id => $photo_id })->insert;

	return;
}

1;

__END__

=head1 NAME

FSpot - Basic tools for manipulating the F-Spot photo database.

=head1 VERSION

This documentation refers to FSpot version 0.1.

=head1 SYNOPSIS

   use FSpot;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head3 C<schema ()>

Return: FSpot::Schema - DBIx::Class schema object

Description: Connects to the F-Spot database and returns the schema object

=head3 C<backup_db ()>

Return: ISO date string - The date used in backing up the database

Description: Backs up the F-Spot database file to a new name with the date
and time appended. It will only do this one per session so it can be safely
called many times.

=head3 C<restore_db ( [$date] )>

Param: C<$date> - ISO date string - The particular date to restore

Description: Restores a previously backed up database. If C<$date> is not
supplied, the last backed up database is restored.

=head3 C<add_roll ( [$time] )>

Param: C<$time> - int - The time to use as the import time (time() is used by default)

Return: int - The added roll_id

Description: Adds a new import roll into the database, also set the roll_id attribute.

=head3 C<roll_id ( [$roll_id] )>

Param: C<$roll_id> - int - This is used to set the roll_id if supplied

Return: int - The last added roll's id

=head3 C<add_photo ($file)>

Param: C<$file> - string - The file of the photo to be added

Return: int - The id of the added photo

Description: Adds the passed file to the photos & photo versions tables

=head3 C<add_photo_version ($file, $photo_id[, $name])>

Param: C<$file> - string - The file of the photo to be added

Param: C<$photo_id> - int - The id of the photo to be added

Param: C<$name> - string - The name of the modified photo version

Return: int - The id of the added photo version

Description: Adds the passed file to the photo versions table referencing
the supplied photo id

=head3 C<add_tag ($tag[, $category_id[, $is_category ] ])>

Param: $tag - string - The name of the tag to be added

Param: $category_id - int - The id of the tag that this tag should belong to.
By default new tags are added to the "Imported Tags" tag

Param: $is_category - bool - Determines if the tag will have sub tags or not

Return: int - The newly added tag_id

Description: Adds a new tag to the database

=head3 C<add_tag_photo ( $tag_id, $photo_id )>

Param: C<$tag_id> - int - The id of the tag to add to the photo

Param: C<$photo_id> - int - The photo which is to be tagged

Description: Associates a tag and a photo

=head3 C<_build_config ( $file )>

Param: C<$file> - string - File name of config

Description: Reads the configuration file for settings

=head3 C<_build_config_file ()>

Description: Determines the most appropriate config file

=head1 DIAGNOSTICS

A list of every error and warning message that the module can generate (even
the ones that will "never happen"), with a full explanation of each problem,
one or more likely causes, and any suggested remedies.

=head1 CONFIGURATION AND ENVIRONMENT

A full explanation of any configuration system(s) used by the module, including
the names and locations of any configuration files, and the meaning of any
environment variables or properties that can be set. These descriptions must
also include details of any configuration language used.

=head1 DEPENDENCIES

A list of all of the other modules that this module relies upon, including any
restrictions on versions, and an indication of whether these required modules
are part of the standard Perl distribution, part of the module's distribution,
or must be installed separately.

=head1 INCOMPATIBILITIES

A list of any modules that this module cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for system
or program resources, or due to internal limitations of Perl (for example, many
modules that use source code filters are mutually incompatible).

=head1 BUGS AND LIMITATIONS

A list of known problems with the module, together with some indication of
whether they are likely to be fixed in an upcoming release.

Also, a list of restrictions on the features the module does provide: data types
that cannot be handled, performance issues and the circumstances in which they
may arise, practical limitations on the size of data sets, special cases that
are not (yet) handled, etc.

The initial template usually just has:

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)
<Author name(s)>  (<contact address>)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
