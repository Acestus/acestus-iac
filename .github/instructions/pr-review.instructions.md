# Pull Request Review Instructions

When reviewing pull requests in this repository, follow these guidelines.

## Review Focus Areas

### .NET Code Quality
- Verify .NET 8.0 compatibility
- Check minimal API best practices
- Ensure proper use of nullable reference types
- Validate dependency injection patterns
- Check for proper error handling

### Docker Best Practices
- Multi-stage builds for smaller images
- Non-root user for security
- Minimal base images (Alpine preferred)
- Health check configured

### Kubernetes Manifests
- Resource limits defined
- Liveness/readiness probes configured
- Appropriate replica counts
- Correct image references

### Infrastructure Changes
- Bicep syntax and best practices
- Environment-specific parameter files
- Proper tagging on all resources
- Security configurations

## Comment Format

Use [Conventional Comments](https://conventionalcomments.org/):

```
issue (blocking): Short description
Detailed explanation of the issue and why it must be fixed.
```

```
issue (non-blocking): Short description
Explanation of the issue. This should be addressed but doesn't block merge.
```

```
suggestion: Short description
Optional improvement that could enhance the code.
```

```
nitpick: Short description
Minor style or formatting issue.
```

## Review Checklist

### For .NET Code
- [ ] Uses .NET 8.0 target framework
- [ ] Nullable reference types enabled
- [ ] Proper use of minimal API patterns
- [ ] Health check endpoints configured
- [ ] No secrets in code

### For Docker Changes
- [ ] Multi-stage build used
- [ ] Production optimized (Release config)
- [ ] Non-root user configured
- [ ] Health check command present

### For Kubernetes Changes
- [ ] Resource requests and limits set
- [ ] Health probes point to correct endpoints
- [ ] Service type appropriate (LoadBalancer/ClusterIP)
- [ ] Environment variables configured

### For Infrastructure Changes
- [ ] Both dev and prd parameter files updated if needed
- [ ] CAF naming conventions followed
- [ ] Required tags included
- [ ] Managed identity used for authentication

### For CI/CD Changes
- [ ] Workflow uses OIDC authentication
- [ ] Build matrix covers all applications
- [ ] Manifest updates committed properly
- [ ] Secrets not exposed in logs
