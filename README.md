# DeusEx

GitHub DDOSings getting you down and stopping your deploys? GIT IS DISTRIBUTED, SUCKA. The deus_ex gem allows you to easily
fire up cloud instance, push your repo to it, and use that for your deploy until GitHub is back on its feet.

## Installation

Add this line to your application's Gemfile:

    gem 'deus_ex'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install deus_ex

The gem uses [fog](http://fog.io/) to manage the connection to various cloud providers, so you'll need to put your credentials into `.machina.yml`, like so:

    ---
    :authentication:
      :provider: 'aws'
      :aws_access_key_id: my_access_key
      :aws_secret_access_key: my_secret_access_key
    :server_create:
      :flavor_ref: 't1.micro'
      :image_ref: 'ami-a9184ac0'
      :key_name: 'bover'
    :username: ubuntu
    :private_key_path: /home/terry/.ssh/bover.pem

Here is an OpenStack example to get a better idea of all the options available:

    ---
    :authentication:
      :provider: 'openstack'
      :openstack_username: '***********'
      :openstack_api_key: '*************'
      :openstack_auth_url: 'https://cloud.example.com:35357/v2.0/tokens'
      :openstack_tenant: 'tenant_name'
      :openstack_region: 'region-b.geo-1'
    :server_create:
      :flavor_ref: '103'
      :image_ref: '8c096c29-a666-4b82-99c4-c77dc70cfb40'
      :key_name: 'bover'
      :nics: [ 'net_id': '76abe0b1-581a-4698-b200-a2e890f4eb8d' ]
    :floating_ip_create:
      :floating_network_id: '7da74520-9d5e-427b-a508-213c84e69616'
    :public_key_path: /home/terry/.ssh/bover.pub
    :private_key_path: /home/terry/.ssh/bover.pem
    :username: ubuntu


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
