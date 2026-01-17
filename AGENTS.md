# Agent Development Standards

This document outlines the coding standards and best practices for AI agents and developers working on the `basic-setup` project.

## Table of Contents

- [Go Standards](#go-standards)
- [Bash Standards](#bash-standards)
- [Documentation Standards](#documentation-standards)
- [Testing Standards](#testing-standards)
- [Version Bumping and CHANGELOG](#version-bumping-and-changelog)
- [Linting and Code Quality](#linting-and-code-quality)

---

## Go Standards

### Idiomatic Go Practices

Follow these industry-standard Go practices:

1. **Code Organization**
   - Use meaningful package names that reflect their purpose
   - Keep packages focused and cohesive
   - Avoid circular dependencies

2. **Naming Conventions**
   - Use `camelCase` for private identifiers
   - Use `PascalCase` for exported identifiers
   - Use descriptive names that clearly indicate purpose
   - Avoid stuttering (e.g., `http.HTTPServer` → `http.Server`)

3. **Error Handling**
   - Always check and handle errors explicitly
   - Don't panic in library code (use errors instead)
   - Wrap errors with context using `fmt.Errorf` with `%w` verb
   - Return errors as the last return value

4. **Formatting and Style**
   - Use `gofmt` or `goimports` to format code
   - Follow the [Effective Go](https://golang.org/doc/effective_go) guidelines
   - Use `golint` and `go vet` to catch common issues

5. **Concurrency**
   - Use channels for communication between goroutines
   - Protect shared state with mutexes or use channels
   - Always document when a function starts a goroutine
   - Use context for cancellation and timeouts

6. **Testing**
   - Write table-driven tests
   - Use meaningful test names (e.g., `TestFunctionName_Scenario`)
   - Test both success and error paths
   - Use subtests for related test cases

### Example Go Code

```go
// Good: Idiomatic Go
func ProcessUser(ctx context.Context, userID string) (*User, error) {
    if userID == "" {
        return nil, fmt.Errorf("userID cannot be empty")
    }

    user, err := fetchUserFromDB(ctx, userID)
    if err != nil {
        return nil, fmt.Errorf("failed to fetch user %s: %w", userID, err)
    }

    return user, nil
}
```

### References

- [Effective Go](https://golang.org/doc/effective_go)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [Uber Go Style Guide](https://github.com/uber-go/guide/blob/master/style.md)

---

## Bash Standards

### Shell Script Best Practices

Follow these industry-standard Bash practices:

1. **Shebang**
   - Use `#! /usr/bin/env bash` for portability
   - Note the space after `#!` as per project convention

2. **Error Handling**
   - Use `set -e` to exit on error
   - Use `set -u` to treat unset variables as errors (optional but recommended)
   - Use `set -o pipefail` to catch errors in pipes
   - Trap errors for cleanup: `trap 'cleanup' EXIT ERR`

3. **Variable Quoting**
   - Always quote variables: `"$variable"` not `$variable`
   - Use `"${variable}"` for clarity in complex expressions
   - Quote command substitutions: `"$(command)"`

4. **Validation and Checks**
   - Validate inputs at the start of the script
   - Check file existence before operations
   - Validate expected formats (e.g., semver, dates)

5. **Functions**
   - Use functions for reusable code blocks
   - Document function purpose with comments
   - Declare local variables with `local`

6. **Logging and Debugging**
   - Use `echo` for user-facing messages
   - Direct errors to stderr: `echo "Error: message" >&2`
   - Exit with non-zero status on errors

### Example Bash Script

```bash
#! /usr/bin/env bash

# Script description: Brief description of what this script does

set -e  # Exit on error
set -o pipefail  # Catch errors in pipes

# Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_FILE="${SCRIPT_DIR}/config.yaml"

# Validate prerequisites
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found at $CONFIG_FILE" >&2
    exit 1
fi

# Function with proper structure
process_data() {
    local input_file="$1"
    local output_file="$2"
    
    if [ -z "$input_file" ] || [ -z "$output_file" ]; then
        echo "Error: Missing required arguments" >&2
        return 1
    fi
    
    # Process the data
    cat "$input_file" > "$output_file"
}

# Main logic
main() {
    local input="${1:-}"
    
    if [ -z "$input" ]; then
        echo "Usage: $0 <input_file>" >&2
        exit 1
    fi
    
    process_data "$input" "output.txt"
    echo "Processing complete"
}

# Run main with all arguments
main "$@"
```

### References

- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [ShellCheck](https://www.shellcheck.net/) for static analysis

---

## Documentation Standards

### Code Documentation

1. **Comments**
   - Write clear, concise comments explaining "why", not "what"
   - Keep comments up-to-date with code changes
   - Use complete sentences with proper punctuation

2. **Function/Method Documentation**
   - Document all exported functions/methods
   - Include parameters, return values, and error conditions
   - Provide usage examples for complex functions

3. **README Files**
   - Include project overview and purpose
   - Document installation and setup steps
   - Provide usage examples
   - List prerequisites and dependencies

4. **CHANGELOG**
   - Follow [Keep a Changelog](https://keepachangelog.com/) format
   - Use semantic versioning
   - Categorize changes: Added, Changed, Deprecated, Removed, Fixed, Security

### Example Documentation

```go
// ProcessPayment processes a payment transaction for the given amount.
// It validates the payment details, charges the payment method, and
// returns a transaction ID on success.
//
// Parameters:
//   - ctx: Context for cancellation and timeouts
//   - paymentID: Unique identifier for the payment
//   - amount: Payment amount in cents (must be positive)
//
// Returns:
//   - transactionID: Unique transaction identifier
//   - error: nil on success, or an error describing the failure
//
// Example:
//   txID, err := ProcessPayment(ctx, "pay_123", 1000)
//   if err != nil {
//       log.Fatalf("Payment failed: %v", err)
//   }
func ProcessPayment(ctx context.Context, paymentID string, amount int) (string, error) {
    // Implementation
}
```

---

## Testing Standards

### Testing Best Practices

1. **Test Coverage**
   - Aim for at least 80% code coverage
   - Test both happy path and error cases
   - Include edge cases and boundary conditions

2. **Test Organization**
   - Use table-driven tests for multiple scenarios
   - Group related tests using subtests
   - Keep tests independent and isolated

3. **Test Naming**
   - Use descriptive test names: `TestFunction_Scenario_ExpectedBehavior`
   - Example: `TestProcessPayment_InvalidAmount_ReturnsError`

4. **Mocking and Fixtures**
   - Use interfaces for dependencies to enable mocking
   - Keep test fixtures minimal and focused
   - Clean up resources after tests

5. **Integration Tests**
   - Separate unit tests from integration tests
   - Use build tags for integration tests: `// +build integration`
   - Document setup requirements for integration tests

### Example Test

```go
func TestProcessUser_ValidInput_ReturnsUser(t *testing.T) {
    tests := []struct {
        name    string
        userID  string
        want    *User
        wantErr bool
    }{
        {
            name:    "valid user ID",
            userID:  "user123",
            want:    &User{ID: "user123", Name: "John"},
            wantErr: false,
        },
        {
            name:    "empty user ID",
            userID:  "",
            want:    nil,
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := ProcessUser(context.Background(), tt.userID)
            if (err != nil) != tt.wantErr {
                t.Errorf("ProcessUser() error = %v, wantErr %v", err, tt.wantErr)
                return
            }
            if !reflect.DeepEqual(got, tt.want) {
                t.Errorf("ProcessUser() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

---

## Version Bumping and CHANGELOG

### Semantic Versioning

Follow [Semantic Versioning 2.0.0](https://semver.org/):

- **MAJOR** version: Incompatible API changes
- **MINOR** version: New functionality, backward compatible
- **PATCH** version: Backward compatible bug fixes

### Version Bumping Process

1. **Determine Version Type**
   - Breaking changes → MAJOR bump
   - New features → MINOR bump
   - Bug fixes → PATCH bump
   - Dependency updates (Dependabot) → PATCH bump

2. **Update Files**
   - Update version in `bsctl/static/resources/constants.yaml`
   - Add CHANGELOG entry with date and changes
   - Follow the CHANGELOG format

3. **CHANGELOG Format**
   ```markdown
   ## [X.Y.Z] - YYYY-MM-DD
   ### Added
   - New feature description

   ### Changed
   - Change description

   ### Fixed
   - Bug fix description
   ```

4. **Automated Bumping**
   - Dependabot PRs are automatically bumped via workflow
   - Manual PRs require manual version bump
   - Always bump version before merging

### Example CHANGELOG Entry

```markdown
## [0.1.5] - 2026-01-17
### Changed
- Bump actions/checkout from v4 to v6
- Updated dependency parsing logic for better robustness

### Fixed
- Fixed CHANGELOG formatting for proper entry separation
```

---

## Linting and Code Quality

### Go Linting

1. **Tools**
   - `gofmt` / `goimports`: Formatting
   - `golint`: Style checks
   - `go vet`: Static analysis
   - `golangci-lint`: Comprehensive linting (recommended)
   - `staticcheck`: Advanced static analysis

2. **Running Linters**
   ```bash
   # Format code
   gofmt -w .
   
   # Run go vet
   go vet ./...
   
   # Run golangci-lint
   golangci-lint run
   ```

3. **CI Integration**
   - All linters must pass in CI
   - Configure linters in `.golangci.yml`
   - Fix all warnings before merging

### Bash Linting

1. **Tools**
   - `shellcheck`: Shell script static analysis
   - `shfmt`: Shell script formatter

2. **Running Linters**
   ```bash
   # Check scripts
   shellcheck script.sh
   
   # Format scripts
   shfmt -w script.sh
   ```

3. **Common Issues to Avoid**
   - Unquoted variables
   - Using `==` in `[ ]` (use `=` or `[[` instead)
   - Not checking command exit codes
   - Missing error handling

### General Code Quality

1. **Pre-commit Checks**
   - Format code before committing
   - Run relevant linters
   - Ensure tests pass locally

2. **Code Review**
   - Address all review comments
   - Update based on feedback
   - Ensure CI passes before requesting review

3. **Continuous Improvement**
   - Refactor complex code
   - Update documentation
   - Add tests for bug fixes

---

## Additional Resources

- [Go by Example](https://gobyexample.com/)
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
- [The Art of Command Line](https://github.com/jlevy/the-art-of-command-line)
- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)

---

**Note**: This document is a living standard and will be updated as the project evolves. All contributors should follow these guidelines to maintain code quality and consistency.
