---
layout: post
comments: true
publish: false
title: You're Deploying it Wrong! - AS Edition (Part 5)
date: 2020-02-20
author: Daniel Otykier
authorurl: http://twitter.com/dotykier
---

This is part 5 of the Analysis Services DevOps blog series. [Go to part 4](https://tabulareditor.github.io/2019/10/17/DevOps4.html)

## Release Pipelines

In the last chapter, we saw how to set up a complete build pipeline, that loads our Tabular model from source control, performs a schema check, runs the best practice analyzer and even performs a validation deployment. At the end, the build pipelines saves and publishes a Model.bim file as an artifact. You can think of this artifact as the "compiled" version of our model, even though it is still just a .json file. The point is, that we can take this file and deploy it to anywhere.

To actually perform the deployment to various environments (Dev, UAT, Prod, etc.), we are going to use the concept of [Release Pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/release/?view=azure-devops) in Azure DevOps.

Within a release pipeline, you define a number of stages, corresponding to the environments you want to deploy to. Within each stage, you can then define a number of tasks
