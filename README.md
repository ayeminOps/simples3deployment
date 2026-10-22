# Vue + S3 + CloudFront (OAI)

A minimal Vue 3 app built with Vite and deployed to a private S3 bucket. CloudFront
uses an Origin Access Identity (OAI) to read the bucket; the bucket is not public.

## Requirements

- Node.js and npm
- AWS CLI configured with credentials that can create CloudFormation, S3, and
  CloudFront resources
- Bash (available by default on Linux/macOS and through WSL on Windows)

## Deploy

From this directory, run:

```bash
bash deploy.sh
```

To choose a different CloudFormation stack name or AWS region:

```bash
bash deploy.sh my-vue-site us-east-1
```

The script builds the app, creates or updates the CloudFormation stack, uploads
`dist/` to its S3 bucket, and invalidates CloudFront's cache. The first
CloudFront distribution can take several minutes to become available.
On Windows, run the script from WSL with Node.js, npm, and AWS CLI installed
inside WSL.

## Develop locally

```bash
npm install
npm run dev
```

CloudFormation provisions the S3 bucket with public access blocked, a CloudFront
OAI and distribution, and a bucket policy granting that identity read-only
access. SPA paths are routed back to `index.html`.
