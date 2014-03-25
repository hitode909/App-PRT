# App::PRT [![Build Status](https://travis-ci.org/hitode909/App-PRT.png?branch=master)](https://travis-ci.org/hitode909/App-PRT) [![Coverage Status](https://coveralls.io/repos/hitode909/App-PRT/badge.png?branch=master)](https://coveralls.io/r/hitode909/App-PRT?branch=master)

Command line tool for Perl code refacoring

## Features

- Replace tokens
- Rename a class

## TODO

- Rename a name space
- Set a method as obsolute

## Setup

```
carton install
```

## Usage

Replace `foo` token with `bar`.
```
carton exec -- bin/prt replace_tokens foo bar lib/**/**.pm
```

Rename `Foo` class to `Bar` class.
```
carton exec -- bin/prt rename_class   Foo Bar lib/**/**.pm
```

Delete `eat` method from  `Food` class.
```
carton exec -- bin/prt delete_method Food eat lib/**/**.pm
```

## License

MIT
