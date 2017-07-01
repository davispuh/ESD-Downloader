# ESD Downloader

Download Windows installation ESD files

## Installation

Install dependecies with Bundler

```
$ bundle
```

## Usage

for command information use `-h` or `--help` flag

`ruby esd-downloader.rb -h`

```
Usage: esd-downloader.rb <command> [options]
Commands: list and download
    -l, --locale LOCALE              Specify locale
    -e, --edition EDITION            Specify edition
    -a, --arch ARCH                  Specify architecture
    -h, --help                       Show this message
```

### In action

```bash
$ ./esd-downloader.rb list --arch x64 --locale pl-pl
--------------------
FileName: 15063.0.170317-1834.rs2_release_CLIENTCombined_RET_x64fre_pl-pl.esd
LanguageCode: pl-pl
Language: Polish
Edition: Professional
Architecture: x64
Size: 2.75 GiB (2953638922 bytes)
SHA1: 126da470b70b794899d48af84a9c6206e8ce3de5
URL: http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2017/03/15063.0.170317-1834.rs2_release_clientcombined_ret_x64fre_pl-pl_126da470b70b794899d48af84a9c6206e8ce3de5.esd
Key: ...
--------------------
--------------------
FileName: 15063.0.170317-1834.rs2_release_CLIENTCombined_RET_x64fre_pl-pl.esd
LanguageCode: pl-pl
Language: Polish
Edition: CoreSingleLanguage
Architecture: x64
Size: 2.75 GiB (2953638922 bytes)
SHA1: 126da470b70b794899d48af84a9c6206e8ce3de5
URL: http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2017/03/15063.0.170317-1834.rs2_release_clientcombined_ret_x64fre_pl-pl_126da470b70b794899d48af84a9c6206e8ce3de5.esd
Key: ...
--------------------
```

```bash
$ ./esd-downloader.rb download --arch x64 --locale uk-ua --edition CoreConnectedSingleLanguage
Downloading 15063.0.170317-1834.rs2_release_CLIENTCombinedSL_RET_x64fre_uk-ua
[################################################] [2982223524/2982223524] [100.00%] [48:26]
Verifying file hash
SHA1 matches ac630b86bb777b6396555895bdaaa3981aa5d52c
Download succesful!
```

## Documentation

YARD with markdown is used for documentation

## Specs

RSpec and simplecov are required, to run tests just `rake spec`
code coverage will also be generated

## Unlicense

![Copyright-Free](http://unlicense.org/pd-icon.png)

All text, documentation, code and files in this repository are in public domain (including this text, README).
It means you can copy, modify, distribute and include in your own work/code, even for commercial purposes, all without asking permission.

[About Unlicense](http://unlicense.org/)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davispuh/ESD-Downloader


**Warning**: By sending pull request to this repository you dedicate any and all copyright interest in pull request (code files and all other) to the public domain. (files will be in public domain even if pull request doesn't get merged)

Also before sending pull request you acknowledge that you own all copyrights or have authorization to dedicate them to public domain.

If you don't want to dedicate code to public domain or if you're not allowed to (eg. you don't own required copyrights) then DON'T send pull request.

