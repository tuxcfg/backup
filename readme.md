Backup tool
===========

## Installation ##

Get from Github and make executable:

```bash
curl \
    --output /usr/local/bin/backup \
    --silent \
    https://raw.githubusercontent.com/tuxcfg/backup/master/backup.sh \
&& chmod +x /usr/local/bin/backup
```


## Usage ##

To backup `books` directory to `backup`:

```bash
backup --source="books" --target="backup"
```

The following directory structure is created:

```
backup
    .head
        books
            book1
            book2
    data
        2019.04.28
            books
                book1
                book2
``` 

The `.head` directory contains the latest copy of `books`.
The `data` directory contains `2019.04.28` as hard links to `.head` directory and does not occupy additional space.

To get only `books` directory content but not `books` itself use trailing slash:

```bash
backup --source="books/" --target="backup"
```

Result:

```
backup
    .head
        book1
        book2
    data
        2019.04.28
            book1
            book2
``` 

Both `--source` and `--target` can be relative or absolute paths.
It's also possible to use multiple paths in `--source`:

```bash
backup --source="books magazines notes" --target="backup"
```

Result:

```
backup
    .head
        books
        magazines
        notes
    data
        2019.04.28
            books
            magazines
            notes
``` 

There is a `--name` option to alter `data/2019.04.28` part:

```bash
backup --source="books notes" --target="backup" --name="daily/`date +%A`"
```

Result:

```
backup
    .head
        books
        notes
    daily
        monday
            books
            notes
``` 

This command being executed on daily basis will create a backup directory for each day of week.
If some day already exists it will be rewritten with the latest content.
This creates a circular backup history with 7 days length.

To get every day backup for the last month:

```bash
backup --source="books notes" --target="backup" --name="daily/`date +%m`"
```

To get every month backup for the last year:

```bash
backup --source="books notes" --target="backup" --name="monthly/`date +%B`"
```

Get all CLI options:

```bash
backup --help
```

Use `--debug` flag with other options to get additional info:

```bash
backup --debug ...
```
