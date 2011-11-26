package Kirby;

use strict;
use warnings;

use Mojo::Base 'Mojolicious';
use FindBin;
use Data::Dumper;

use Kirby::Database;
use Kirby::Scraper::SimpleScraper;

sub startup {
    my $self = shift;

    $self->secret('Kirby Default');

    my $r = $self->routes;

    $r->any('/' => sub {
        my $self = shift;
        $self->stash(
            head => "Kirby",
        );
        $self->render('index');
    } => 'index');

    $r->any('/dump' => sub {
        my $self = shift;
        my @result;
        Kirby::Database::Kirby->iterate( sub {
                push @result, $_->series." | ".$_->issue;
            } );
        $self->stash(results => [ @result ],);
    } => 'dump');

    $r->any('/search' => sub {
        my $self = shift;
        my $q = $self->param('q') || undef;
        if ( defined $q ) {
            my $scrape = Kirby::Scraper::SimpleScraper->new( directory => '/export/Comics', );
            $scrape->search( q => $q, );
            $self->render(
                text => "sucessful query to SimpleScraper",
            );
        }
        else {
            $self->render(
                text => "Something's wrong",
            );
        };
    });

    $r->any('/add'  => sub {
        my $self = shift;
        my $series = $self->param('series') || undef;
        my $volume = $self->param('vol') || undef;
        my $issue = $self->param('issue') || undef;
        my $title = $self->param('title') || 'N/A';
        my $description = $self->param('desc') || 'N/A';
        if ( (defined $series) and (defined $volume) and (defined $issue) ) {
            my $comicID = Kirby::Database::Kirby->create(
                series => $series,
                volume => $volume,
                issue  => $issue,
                title  => $title,
                description => $description,
            );
            $self->render(
                text => "Inserted $series $volume $issue",
            );
        }
        else {
            $self->render(
                text => "Missing required fields",
            );
        };
    });
}

1;
