package LoaderTestFoo;
sub bar { }

package LoaderTest;

use strict;
use warnings;

use base 'TestBase';

use lib 't/core/LoaderTest';

use Test::More;
use Test::Fatal;

use Turnaround::Loader;

sub know_when_class_is_already_loaded : Test {
    my $self = shift;

    my $loader = $self->_build_loader;

    ok($loader->is_class_loaded('LoaderTest'));
}

sub load_loaded_class : Test {
    my $self = shift;

    my $loader = $self->_build_loader;

    is($loader->load_class('LoaderTest'), 'LoaderTest');
}

sub load_existing_class_searching_namespaces : Test {
    my $self = shift;

    my $loader = $self->_build_loader(namespaces => [qw/Foo:: Bar::/]);

    is($loader->load_class('Class'), 'Bar::Class');
}

sub throw_on_invalid_class_name : Test {
    my $self = shift;

    my $loader = $self->_build_loader;

    ok(exception { $loader->load_class('@#$@') });
}

sub throw_on_unknown_class : Test {
    my $self = shift;

    my $loader = $self->_build_loader;

    isa_ok(
        exception { $loader->load_class('Unknown') },
        'Turnaround::Exception::ClassNotFound'
    );
}

sub throw_on_class_with_syntax_errors : Test {
    my $self = shift;

    my $loader = $self->_build_loader;

    isa_ok(exception { $loader->load_class('WithSyntaxErrors') },
        'Turnaround::Exception::Base');
}

sub throw_on_class_with_syntax_errors2 : Test(2) {
    my $self = shift;

    my $loader = $self->_build_loader;

    my $e = exception { $loader->load_class('WithSyntaxErrors') };
    isa_ok($e, 'Turnaround::Exception::Base');

    $e = exception { $loader->load_class('WithSyntaxErrors') };
    isa_ok($e, 'Turnaround::Exception::Base');
}

sub is_class_loaded : Test(1) {
    my $self = shift;

    my $loader = $self->_build_loader;

    ok($loader->is_class_loaded('LoaderTestFoo'));
}

sub not_is_class_loaded : Test(1) {
    my $self = shift;

    my $loader = $self->_build_loader;

    ok(!$loader->is_class_loaded('Foo123'));
}

sub _build_loader {
    my $self = shift;

    return Turnaround::Loader->new(@_);
}

1;
