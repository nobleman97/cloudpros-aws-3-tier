# Perizer Terraform Module Template Repo
This is the base Terraform Module Template Repo used for creating new Terraform modules.

## Benefits of Terraform Module
- Reusability and Standardization: Use pre-defined infrastructure components for consistent deployments.
- Consistency and Scalability: Provision infrastructure reliably and scale deployments efficiently.
- Collaboration and Efficiency: Foster collaboration, code reuse, and best practices.
- Maintainability and Upgradability: Simplify maintenance and updates of infrastructure configurations.
- Versioning and Testing: Track changes, validate functionality, and ensure compatibility.
- Governance and Compliance: Enforce governance and comply with security and industry requirements.

## Release Description
# This is a release description template that should be updated for each release.

# Terraform AzureRM Module - Release X.X.X
Release Date: YYYY-MM-DD

## Changelog
Summarize the major changes and updates made in this release. Provide a high-level overview of new features, enhancements, and bug fixes.

## New Features
- Feature 1: Description of the new feature.
- Feature 2: Description of the new feature.

## Enhancements
- Enhancement 1: Description of the enhancement.
- Enhancement 2: Description of the enhancement.

## Bug Fixes
- Bug Fix 1: Description of the bug fix.
- Bug Fix 2: Description of the bug fix.

## Breaking Changes
- List any changes that might affect the existing infrastructure or configurations. Provide guidance on how users can update their existing deployments to adapt to these changes.

## Compatibility
- Describe the compatibility of this module with different versions of Terraform, AzureRM provider, and any other dependencies.

## Installation
- Instructions and dependencies can be found in the updated README.md.

## Usage Examples
- Provide updated examples on how to use the module effectively in different scenarios.

## Documentation
- Updated README with comprehensive module usage instructions and detailed input output descriptions.
- Linked to Azure documentation for additional context and resources.

## Support
- For any questions or issues related to this module, please create a JIRA [ticket](https://perizer.atlassian.net/jira/software/c/projects/CLOUD/boards/11).


## Versioning
- [Semantic versioning](https://semver.org/#semantic-versioning-200), Given a version number MAJOR.MINOR.PATCH, increment the:
    - MAJOR version when you make incompatible API changes
    - MINOR version when you add functionality in a backward compatible manner
    - PATCH version when you make backward compatible bug fixes

---
<!-- BEGIN_TF_DOCS -->
{{ .Content }}
<!-- END_TF_DOCS -->