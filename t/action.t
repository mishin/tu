use strict;
use warnings;
use utf8;

use Test::More tests => 31;

use_ok('Lamework::Action');

use Encode ();

use Lamework::Routes;
use Lamework::Registry;
use Lamework::Displayer;
use Lamework::Renderer::Caml;

my $routes = Lamework::Routes->new;
$routes->add_route('/:action/:id', name => 'action');

Lamework::Registry->set(routes => $routes);

my $displayer = Lamework::Displayer->new(
    default_format => 'caml',
    formats =>
      {caml => Lamework::Renderer::Caml->new(templates_path => 't/action')}
);

Lamework::Registry->set(displayer => $displayer);

my $match = $routes->match('/action/1');

my $env = {
    HTTP_HOST               => 'localhost',
    QUERY_STRING            => 'foo=bar',
    'lamework.routes.match' => $match
};

my $action = Lamework::Action->new(env => $env);
is $action->captures->{id}    => 1;
is $action->req->param('foo') => 'bar';

is $action->url_for('action', action => 'action', id => 2) =>
  'http://localhost/action/2';
is $action->url_for('http://google.com') => 'http://google.com';
is $action->url_for('/')                 => 'http://localhost/';
is $action->url_for('/foo')              => 'http://localhost/foo';
is $action->url_for('/bar/')             => 'http://localhost/bar/';

eval { $action->redirect('action', action => 'foo', id => 3); };
isa_ok($@, 'Lamework::HTTPException');
is $@->location => 'http://localhost/foo/3';

eval { $action->redirect('/bar/'); };
is $@->location => 'http://localhost/bar/';

$action = Lamework::Action->new(env => $env);
$action->render_file('template.caml');
is $action->res->code => 200;
is $action->res->body => 'Hello there!';

$action = Lamework::Action->new(env => $env);
$action->render_file('template', layout => 'layout');
is $action->res->code => 200;
is $action->res->body => "Before\nHello there!\nAfter";

my $env_ = {%$env, 'lamework.displayer' => {'layout' => 'layout'}};
$action = Lamework::Action->new(env => $env_);
$action->render_file('template');
is $action->res->code => 200;
is $action->res->body => "Before\nHello there!\nAfter";

$action = Lamework::Action->new(env => $env);
$action->render_file('template_utf8');
is $action->res->code => 200;
is $action->res->body => Encode::encode('UTF-8', "привет");

$action = Lamework::Action->new(env => $env);
eval { $action->forbidden };
isa_ok($@, 'Lamework::HTTPException');
is $@->code      => 403;
is $@->as_string => 'Forbidden!';

$action = Lamework::Action->new(env => $env);
eval { $action->not_found };
isa_ok($@, 'Lamework::HTTPException');
is $@->code      => 404;
is $@->as_string => 'Not Found!';

$action = Lamework::Action->new(env => $env);
eval { $action->serve_file('unknown'); };
isa_ok($@, 'Lamework::HTTPException');
is $@->code => 404;

$action = Lamework::Action->new(env => $env);
$action->serve_file('t/action/static.txt');
is $action->res->code => 200;
$action->res->body->read(my $buf, 1024);
is $buf => "Static file!\n";

$action = Lamework::Action->new(env => $env);
eval { $action->run; };
ok $@;

$action = Lamework::Action->new(env => $env, cb => sub {'Hello'});
is($action->run, 'Hello');

1;
