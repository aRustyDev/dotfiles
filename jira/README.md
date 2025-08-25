# Install
```bash
# Create the configuration directory in your home folder
mkdir -p ~/.jira.d/templates

# Create the main configuration file
touch ~/.jira.d/config.yml

# Ensure you have Go modules enabled
export GO111MODULE=on

# Install go-jira directly from the repository
go install github.com/go-jira/jira/cmd/jira@latest

# Verify the installation
jira version
```
