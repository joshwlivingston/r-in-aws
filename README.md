# r-in-aws

Demo repo (Claude-assisted) showcasing how to deploy an R package as an AWS Lambda function using Docker.

## Prerequisites

- **R 4.5.2** - Must match version in `renv.lock`
- **Docker** - For building container images
- **Terraform** - For AWS infrastructure
- **AWS CLI** - Configured with appropriate credentials

## Project Organization

```
├── src/                             # R package
│   ├── R/
│   │   ├── 00_S7.R                  # S7 class definitions (00 prefix ensures load order)
│   │   ├── average-lift.R           # fit() and average_lift() generics
│   │   ├── aws.R                    # fetch_data() generic
│   │   └── zzz.R                    # Package startup
│   ├── tests/testthat/              # Unit tests
│   ├── DESCRIPTION
│   └── NAMESPACE
│
├── terraform/
│   ├── environments/                # Environment-specific configs
│   │   ├── dev/
│   │   └── prod/
│   └── modules/
│       ├── ecr/                     # Container registry
│       └── lambda/                  # Lambda function
│
├── scripts/
│   ├── setup/
│   │   ├── once-per-project/        # One-time project setup (S3 backend)
│   │   └── for-each-environment/    # Per-env setup (terraform init, ECR)
│   ├── tests/
│   │   ├── test-src-R.sh            # Run R package tests
│   │   └── test-build.sh            # Docker build smoke test
│   └── build.sh                     # Build and push Docker image
│
├── .github/workflows/
│   ├── ci.yml                       # CI orchestrator (PRs and pushes to main)
│   ├── deploy-dev.yml               # Auto-deploy to dev on CI success
│   └── deploy-prod.yml              # Manual production deployment
│
├── data/                            # Sample data (uploaded to S3)
├── renv/                            # R packages (managed by renv)
├── runtime.R                        # Lambda entry point
├── Dockerfile
├── renv.lock
└── .Rprofile                        # Activates renv
```

## R Package Structure

The R package uses S7 for object-oriented design:

| Class | Purpose |
|-------|---------|
| `S3DataSource` | Reads config from `S3_BUCKET_NAME` and `S3_DATA_KEY` env vars |
| `LiftAnalysis` | Main model class; fetches data on construction, validates spend column |
| `LiftSimResults` | Typed container for simulation output (S3 class wrapping numeric vector) |

Generic functions:
- `fetch_data(source)` - retrieves CSV data from S3
- `fit(model, scaling_factor)` - runs simulation, returns `LiftSimResults`
- `average_lift(x, na.rm)` - calculates mean of simulation results

## Terraform Structure

Infrastructure follows an environment/module pattern:

- **Environments** (`terraform/environments/`): environment-specific variables and backend config
- **Modules** (`terraform/modules/`): reusable ECR and Lambda resources

State stored in S3 backend.

## Testing

### R Package

The R package contains tests that can be ran locally, without AWS:

```bash
./scripts/tests/test-src-R.sh
```

## Build

Build locally:
```bash
./scripts/build.sh
```

Test the build after building:
```bash
./scripts/tests/test-build.sh
```

## CI/CD

Automated via GitHub Actions:

| Workflow | Trigger | Action |
|----------|---------|--------|
| `ci.yml` | PR or push to main | R CMD CHECK + Docker smoke test |
| `deploy-dev.yml` | CI success on main | Build, push to ECR, deploy to dev |
| `deploy-prod.yml` | Manual dispatch | Full CI, deploy to dev, then prod |

Both deployment workflows include a post-deploy smoke test that invokes the Lambda function.

## Invoking the Lambda

```bash
aws lambda invoke --function-name calculate_lift_dev \
  --payload '{"scaling_factor": 2.0}' \
  --cli-binary-format raw-in-base64-out \
  response.json
```
