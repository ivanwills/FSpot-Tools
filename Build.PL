use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name         => 'FSpot',
	license             => 'perl',
	dist_author         => 'Ivan Wills <ivan.wills@gmail.com>',
	dist_version_from   => 'lib/FSpot.pm',
	reqires             => {
		'Image::ExifTool'                       => 0,
		'Catalyst::Helper::Model::DBIC::Schema' => 0,
		'DBIx::Class::Schema::Loader'           => 0,
	},
	build_requires => {
		'Test::More' => 0,
	},
	add_to_cleanup     => [ 'FSpot-*' ],
	create_makefile_pl => 'traditional',
	create_license     => 1,
);

$builder->create_build_script();
