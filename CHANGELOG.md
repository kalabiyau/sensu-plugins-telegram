# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]
## [2.0.0] - 2017-05-30
### Breaking Change
- removed ruby 1.9x support

### Changed
- updated authors, email, homepage in .gemspec
- misc repo cleanup

## [1.0.1] - 2017-05-29
### Changed
- just fixing the ruby api key in .travis.yml for rubygems

## [1.0.0] - 2017-05-29
### Added
 - Support for custom message erb templates

## [0.2.0] - 2016-03-23
### Added
 - Emojis!
 - The json_config command line option, which lets you specify custom configs
   for different handlers.
 - the bot_token and error_file_location settings can also be specified
   directly in the event data.

### Fixed
 - Correctly escape HTML entities, so that the TG API doesn't barf at invalid
   HTML.

## [0.1.1] - 2016-03-18
### Changed
 - Depend on sensu-plugin ~> 1.1 instead of ~> 1.2.

## 0.1.0 - 2016-03-18
### Added
- Initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-telegram/compare/2.0.0...HEAD
[2.0.0]: https://github.com/sensu-plugins/sensu-plugins-telegram/compare/1.0.1...2.0.0
[1.0.1]: https://github.com/sensu-plugins/sensu-plugins-telegram/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/sensu-plugins/sensu-plugins-telegram/compare/v0.2.0...1.0.0
[0.2.0]: https://github.com/sensu-plugins/sensu-plugins-telegram/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/sensu-plugins/sensu-plugins-telegram/compare/v0.1.0...v0.1.1
