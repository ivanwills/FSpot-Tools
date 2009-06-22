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
use base qw/Exporter/;
use Config::General;
use FSpot::Schema;
use FindBin qw/$Bin/;
use Path::Class;
use DateTime;
use File::Copy qw/copy/;

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
	isa => 'Bool',
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

	$self->backed_up(1);

	return;
}

1;

__END__

=head1 NAME

FSpot - <One-line description of module's purpose>

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

Description: Backs up the F-Spot database file to a new name with the date
and time appended. It will only do this one per session so it can be safely
called many times.

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
