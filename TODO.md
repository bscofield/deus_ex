Provide a script to:

1. Provision an AWS micro instance
2. Set it up to host a public git repo
3. Push the current git repo to the AWS instance
  1. Add a remote pointing to the AWS instance
  2. Push to the remote
  3. Removes the remote
4. Displays the public git URL for use in a deployment
5. Provides a means to deprovision the instance after the deploy is done

Additionally, there should be a Capistrano plugin that:

1. Does 1-3 above
2. Uses the public git URL for a live deploy
3. Automatically deprovisions the instance after the deploy is done