# Perl Refactoring Tools [![Build Status](https://travis-ci.org/hitode909/perl-refactoring-tools.png?branch=master)](https://travis-ci.org/hitode909/perl-refactoring-tools)

Command line tool for Perl code refacoring

## Features

WIP

## TODO

- Replace tokens
- Rename a class
- Rename a name space
- Set a method as obsolute

## Setup

```
carton install
```

## Usage

```
carton exec -- bin/prt replace_tokens foo bar lib/**/**.pm
carton exec -- bin/prt rename_class   Foo Bar lib/**/**.pm
```

## Examples

### Replace token
```
% prt replace_token preload_app please_prepare_app lib/**/**.pm
% git status
# On branch master
# Changes not staged for commit:
#   (use "git add <file>..." to update what will be committed)
#   (use "git checkout -- <file>..." to discard changes in working directory)
#
#       modified:   lib/Plack/Loader.pm
#       modified:   lib/Plack/Loader/Delayed.pm
#       modified:   lib/Plack/Loader/Restarter.pm
#       modified:   lib/Plack/Loader/Shotgun.pm
#       modified:   lib/Plack/Runner.pm
#
no changes added to commit (use "git add" and/or "git commit -a")
% git diff lib/Plack/Loader.pm
diff --git a/lib/Plack/Loader.pm b/lib/Plack/Loader.pm
index bf8d250..0ef3c8d 100644
--- a/lib/Plack/Loader.pm
+++ b/lib/Plack/Loader.pm
@@ -50,7 +50,7 @@ sub load {
     }
 }

-sub preload_app {
+sub please_prepare_app {
     my($self, $builder) = @_;
     $self->{app} = $builder->();
 }
```

### Rename class

```
% prt rename_class Plack::Request Plack::Gift lib/**/**.pm
% git status
# On branch master
# Changes not staged for commit:
#   (use "git add/rm <file>..." to update what will be committed)
#   (use "git checkout -- <file>..." to discard changes in working directory)
#
#       modified:   lib/Plack/App/Directory.pm
#       deleted:    lib/Plack/Request.pm
#       modified:   lib/Plack/Test/Suite.pm
#
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#       lib/Plack/Gift.pm
% prt rename_class Plack::Request Plack::Gift lib/**/**.pm
diff --git a/lib/Plack/App/Directory.pm b/lib/Plack/App/Directory.pm
index 77c8c97..e0e6cc9 100644
--- a/lib/Plack/App/Directory.pm
+++ b/lib/Plack/App/Directory.pm
@@ -7,7 +7,7 @@ use HTTP::Date;
 use Plack::MIME;
 use DirHandle;
 use URI::Escape;
-use Plack::Request;
+use Plack::Gift;

 # Stolen from rack/directory.rb
 my $dir_file = "<tr><td class='name'><a href='%s'>%s</a></td><td class='size'>%s</td><td class='type'>%s</td><td cl
ass='mtime'>%s</td></tr>";
@@ -45,7 +45,7 @@ sub should_handle {

 sub return_dir_redirect {
     my ($self, $env) = @_;
-    my $uri = Plack::Request->new($env)->uri;
+    my $uri = Plack::Gift->new($env)->uri;
     return [ 301,
         [
             'Location' => $uri . '/',```
```

## License

MIT
