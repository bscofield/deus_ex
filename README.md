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

The gem uses [fog](http://fog.io/) to manage the connection to AWS, so you'll need to put your AWS credentials into `~/.fog`, like so:

    default:
      aws_access_key_id: my_access_key
      aws_secret_access_key: my_secret_access_key
      public_key_path: ~/.ssh/id_rsa.pub
      private_key_path: ~/.ssh/id_rsa

## Usage

Once the gem's bundled, run the following to create your temporary instance:

    $ bundle exec deus_ex

The gem will tell you what it's doing, and will give you the git URL for your new deploy-fromable repo. Use that for your deploy, then tear down your instance with

    $ bundle exec deus_ex cleanup

You can check to see if you have any active deus_ex instances running, as well:

    $ bundle exec deus_ex status

## Warning!

This may not work if your app has dependencies on GitHub beyond the deployment repository -- if you're using git URLs for gems, for instance.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
