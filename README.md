# DeusEx

GitHub DDOSings getting you down and stopping your deploys? GIT IS DISTRIBUTED, SUCKA. The deus_ex gem allows you to easily
fire up an AWS instance, push your repo to it, and use that for your deploy until GitHub is back on its feet.

## Installation

Add this line to your application's Gemfile:

    gem 'deus_ex'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install deus_ex

## Usage

Once the gem's bundled, run the following to create your temporary instance:

    $ bundle exec deus_ex

The gem will tell you what it's doing, and will give you the git URL for your new deploy-fromable repo. Use that for your deploy,
then tear down your instance with

    $ bundle exec deus_ex cleanup

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
