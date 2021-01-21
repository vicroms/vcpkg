# Versioning: Implementation Details

## Contents

* [Version schemes](#versioning-schemes)
* [Version files](#version-files)
* [Version resolution](#version-conflicts)

## Version schemes
Versions are an important part of a package’s upstream metadata. Ports in vcpkg should attempt to follow the versioning conventions used by the package’s authors. For that reason, when declaring a package’s version the appropriate scheme should be used.

Each versioning scheme defines their own rules on what is a valid version string and more importantly the rules for how to sort versions using the same scheme.

The versioning schemes understood by vcpkg are:

Manifest property | Versioning scheme
------------------|------------------------------------
`version`         | For dot-separated numeric versions
`version-semver`  | For SemVer compliant versions
`version-date`    | For dates in the format YYYY-MM-DD
`version-string`  | For arbitrary strings

A manifest must contain only one version declaration.

#### `version`
Accepts version strings that follow a relaxed, dot-separated-, semver-like scheme.

The version is logically composed of dot-separated (`.`) numeric sections. Each section must contain an integer positive number with no leading zeroes.

The regex pattern for this versioning scheme is: `(0|[1-9]\d*)(\.(0|[1-9]\d*))*`

_Sorting behavior_: When comparing two versions, each section is compared from left to right by their numeric value, until the first difference is found. A version with the smallest set of sections takes precedence over another with a larger set of sections, given that all their preceding sections compare equally.

Example:  
`0` < `0.1` < `0.1.0` < `1` < `1.0.0` < `1.0.1` < `1.1`< `2.0.0`

#### `version-semver`
Accepts version strings that follow semantic versioning conventions as described in the [semantic versioning specification](https://semver.org/#semantic-versioning-specification-semver).

_Sorting behavior_: Strings are sorted following the rules described in the semantic versioning specification.

Example: 
`1.0.0-1` < `1.0.0-alpha` < `1.0.0-beta` < `1.0.0` < `1.0.1` < `1.1.0`

#### `version-date`

Accepts version strings that can be parsed to a date following the ISO-8601 format `YYYY-MM-DD`. Disambiguation identifiers are allowed in the form of dot-separated-, positive-, integer-numbers with no leading zeroes.

The regex pattern for this versioning scheme is: `\d{4}-\d{2}-\d{2}(\.(0|[1-9]\d*))*`

_Sorting behavior_: Strings are sorted first by their date part, then by numeric comparison of their disambiguation identifiers. Disambiguation identifiers follow the rules of the relaxed (`version`) scheme.

Examples:
`2021-01-01` < `2021-01-01.1` < `2021-02-01.1.2` < `2021-02-01.1.3` < `2021-02-01`

#### `version-string`
For packages using version strings that do not fit any of the other schemes, it accepts most arbitrary strings.  The `#` which is used to denote port versions is disallowed.

_Sorting behavior_: No sorting is attempted on the version string itself. However, if the strings match exactly, their port versions can be compared and sorted.

Examples: 
* `apple` <> `orange` <> `orange.2` <> `orange2`  
* `watermelon#0`< `watermelon#1`

#### `port-version`
A positive integer value that increases each time a vcpkg-specific change is made to the port.  

The rules for port versions are:
* Start at 0 for the original version of the port,
* increase by 1 each time a vcpkg-specific change is made to the port that does not increase the version of the package,
* and reset to 0 each time the version of the package is updated.

_NOTE: Whenever vcpkg output a version it follows the format `<version>#<port version>`. For example `1.2.0#2` means version `1.2.0` port version `2`. When the port version is `0` the `#0` suffix is omitted (`1.2.0` implies version `1.2.0` port version `0`)._

_Sorting behavior_: If two versions compare equally, their port versions are compared by their numeric value, lower port versions take precedence.

Examples:
* `1.2.0` < `1.2.0#1` < `1.2.0#2` < `1.2.0#10`
* `2021-01-01#20` < `2021-01-01.1`
* `windows#7` < `windows#8`

## Version files

## Version resolution