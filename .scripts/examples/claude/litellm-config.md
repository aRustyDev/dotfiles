# LiteLLM Configuration for Claude

This document explains how to configure Claude to work with a LiteLLM proxy server for API request routing and management.

## Overview

LiteLLM is a proxy server that can route requests to various LLM providers (OpenAI, Anthropic, etc.) with features like:
- Load balancing
- Rate limiting
- Cost tracking
- Caching
- Authentication

## Environment Variables

```bash
# Refresh API key every hour (3600000 milliseconds)
export CLAUDE_CODE_API_KEY_HELPER_TTL_MS=3600000

# Configure LiteLLM proxy endpoint
export ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock

# Skip Bedrock authentication (LiteLLM handles it)
export CLAUDE_CODE_SKIP_BEDROCK_AUTH=1

# Enable Bedrock mode
export CLAUDE_CODE_USE_BEDROCK=1
```

## Dynamic API Key Management

### Option 1: Vault Integration

If your API keys are stored in HashiCorp Vault:

```bash
#!/bin/bash
# ~/bin/get-litellm-key.sh

# Fetch the API key from Vault
vault kv get -field=api_key secret/litellm/claude-code
```

### Option 2: JWT Token Generation

For JWT-based authentication:

```bash
#!/bin/bash
# ~/bin/generate-litellm-jwt.sh

# Generate a JWT token that expires in 1 hour
jwt encode \
  --secret="${JWT_SECRET}" \
  --exp="+1h" \
  '{"user":"'${USER}'","team":"engineering"}'
```

### Option 3: Environment-based Key Rotation

For simpler setups:

```bash
#!/bin/bash
# ~/bin/refresh-litellm-key.sh

# Source the key from a secure location
source ~/.secrets/litellm.env
echo "${LITELLM_API_KEY}"
```

## Complete Setup Script

Create a script to configure Claude with LiteLLM:

```bash
#!/bin/bash
# ~/.config/claude/setup-litellm.sh

# Check if LiteLLM server is reachable
if ! curl -s -o /dev/null -w "%{http_code}" https://litellm-server:4000/health | grep -q "200"; then
    echo "Error: LiteLLM server is not reachable"
    exit 1
fi

# Set up environment variables
export CLAUDE_CODE_API_KEY_HELPER="$HOME/bin/get-litellm-key.sh"
export CLAUDE_CODE_API_KEY_HELPER_TTL_MS=3600000
export ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock
export CLAUDE_CODE_SKIP_BEDROCK_AUTH=1
export CLAUDE_CODE_USE_BEDROCK=1

# Optional: Set request timeout
export CLAUDE_CODE_REQUEST_TIMEOUT_MS=60000

# Optional: Enable debug logging
# export CLAUDE_CODE_DEBUG=1

echo "LiteLLM proxy configuration applied successfully"
```

## Usage

1. Make the helper script executable:
   ```bash
   chmod +x ~/bin/get-litellm-key.sh
   ```

2. Source the setup script in your shell profile:
   ```bash
   # Add to ~/.zshrc or ~/.bashrc
   source ~/.config/claude/setup-litellm.sh
   ```

3. Verify the configuration:
   ```bash
   claude-code --version
   ```

## Troubleshooting

### Connection Issues
- Verify LiteLLM server URL is correct
- Check network connectivity
- Ensure SSL certificates are valid

### Authentication Failures
- Verify API key helper script returns valid key
- Check JWT token expiration
- Ensure Vault credentials are current

### Debug Mode
Enable debug logging to troubleshoot issues:
```bash
export CLAUDE_CODE_DEBUG=1
claude-code
```

## Security Considerations

1. **API Key Storage**: Never hardcode API keys. Always use secure storage like Vault or encrypted environment files.

2. **Network Security**: Always use HTTPS for LiteLLM proxy connections.

3. **Key Rotation**: Set appropriate TTL for API keys based on your security policies.

4. **Access Control**: Restrict access to API key helper scripts:
   ```bash
   chmod 700 ~/bin/get-litellm-key.sh
   ```

## Additional Resources

- [LiteLLM Documentation](https://docs.litellm.ai/)
- [Claude Code Configuration Guide](https://docs.anthropic.com/claude-code/configuration)
- [Vault CLI Documentation](https://www.vaultproject.io/docs/commands)