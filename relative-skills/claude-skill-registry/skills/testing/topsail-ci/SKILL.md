---
name: topsail-ci
description: Suite of tools to fetch TOPSAIL CI logs and artifacts for test troubleshooting
---

# TOPSAIL CI artifacts retriever

To troubleshoot TOPSAIL CI runs, you need to download the CI logs, and
if necessary to investigate further, download the CI artifacts to
better understand what happened.

To download the CI logs, you need to ask the user the PR number (`PR_NUMBER`).
1. With the PR number, find the list of available tests, by fetching this listing page:

> https://gcsweb-ci.apps.ci.l2s4.p1.openshiftapps.com/gcs/test-platform-results/pr-logs/pull/openshift-psap_topsail/PR_NUMBER

usually, there's only one test `TEST_NAME`

2. With the test name, find the latest build ID (the build ID is a timestamp) `BUILD_ID`

> https://gcsweb-ci.apps.ci.l2s4.p1.openshiftapps.com/gcs/test-platform-results/pr-logs/pull/openshift-psap_topsail/PR_NUMBER/TEST_NAME/latest-build.txt

3. With the Build ID, look up the steps on this page:

> https://gcsweb-ci.apps.ci.l2s4.p1.openshiftapps.com/gcs/test-platform-results/pr-logs/pull/openshift-psap_topsail/PR_NUMBER/TEST_NAME/BUILD_ID/artifacts/jump-ci/

4. The following steps `STEP_NAME` are the setup of the infrastructure (the `jump-ci`):
- `lock-cluster`
- `prepare-jump-ci`
- `unlock-cluster`

If they fail, it's an infra-structure failure. This should be clearly specified to the user, but she'll nonetheless need help to know which part failed.
Their artifacts directory is at this location:

> https://gcsweb-ci.apps.ci.l2s4.p1.openshiftapps.com/gcs/test-platform-results/pr-logs/pull/openshift-psap_topsail/PR_NUMBER/TEST_NAME/BUILD_ID/artifacts/jump-ci/STEP_NAME/artifacts/

5. These steps are the actual test steps:
- `pre-cleanup`
- `prepare`
- `test`
- `post-cleanup` (optional)

Their artifacts are at this location:

> https://gcsweb-ci.apps.ci.l2s4.p1.openshiftapps.com/gcs/test-platform-results/pr-logs/pull/openshift-psap_topsail/PR_NUMBER/TEST_NAME/BUILD_ID/artifacts/jump-ci/STEP_NAME/artifacts/test-artifacts/

Notice the trailing `test-artifacts` directory name. This directory is created by the Jump-CI. Anything inside it is the actual test artifacts. Anything at the same level is the artifacts of the Jump-CI infrastructure.

6. Inside the test artifacts directory, the `run.log` file shows the full trace of the

> https://gcsweb-ci.apps.ci.l2s4.p1.openshiftapps.com/gcs/test-platform-results/pr-logs/pull/openshift-psap_topsail/PR_NUMBER/TEST_NAME/BUILD_ID/artifacts/jump-ci/STEP_NAME/artifacts/test-artifacts/run.log

this file might be long and hard to grasp (for the user).

7. Inside the test artifacts directory, the `FAILURES` file, if present, gives an indication of what failed:

> https://gcsweb-ci.apps.ci.l2s4.p1.openshiftapps.com/gcs/test-platform-results/pr-logs/pull/openshift-psap_topsail/PR_NUMBER/TEST_NAME/BUILD_ID/artifacts/jump-ci/STEP_NAME/artifacts/test-artifacts/FAILURES

8. This command helps downloading locally a full directory `DIRECTORY` of artifacts:

> gsutil -m cp -r gs://test-platform-results/pr-logs/pull/openshift-psap_topsail/PR_NUMBER/TEST_NAME/BUILD_ID/artifacts/jump-ci/STEP_NAME/artifacts/test-artifacts/DIRECTORY .

(the command is also shown at the bottom of the directory listing).
