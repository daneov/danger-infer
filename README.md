![Build status](https://travis-ci.org/daneov/danger-infer.svg?branch=master)
# danger-infer

[Infer](https://github.com/facebook/infer) is Facebook's statistical analysis tool for Java, C and Objective-C.

This plugin allows you to get a summary of those results on your PR, giving you a quick overview on how your codebase is holding up.

## Installation

For now: 

    * Fork this repo
    * Checkout your forked version 
    $ gem build danger-infer.gemspec
    $ gem install danger-infer-x.y.z
    
Somehwere in the future: 

    $ gem install danger-infer

## Usage

    Methods and attributes from this plugin are available in
    your `Dangerfile` under the `infer` namespace.

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.

**N.B**: For now I'm focussing on the Objective-C part, but if you feel like some improvement is needed here, don't hold back and contribute 😉