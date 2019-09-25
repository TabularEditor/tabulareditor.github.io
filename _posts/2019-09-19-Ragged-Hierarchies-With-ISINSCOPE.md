---
layout: post
comments: true
title: Ragged Hierarchies with ISINSCOPE
publish: false
date: 2019-09-19
author: Daniel Otykier
authorurl: http://twitter.com/dotykier
---

Seasoned Tabular and Power BI data modellers have often come across ragged or unbalanced hierarchies. When working exclusively with MDX clients, such as Excel, we can use the [HideMembers property](https://docs.microsoft.com/en-us/analysis-services/tutorial-tabular-1400/as-supplemental-lesson-ragged-hierarchies#to-fix-the-ragged-hierarchy-by-setting-the-hide-members-property) to instruct the Tabular engine to skip blank levels when drilling down through a hierarchy.

Unfortunately, this technique does not work for DAX clients, so setting HideMembers to `HideBlankMembers` has no effect when visualising data in Power BI.

The definitive resource for handling hierarchies that might be ragged or unbalanced, is the [Parent-Child Hierarchy DAX Pattern](https://www.daxpatterns.com/parent-child-hierarchies/). This pattern describes a technique for flattening a Parent-Child hierarchy using DAX. For a ragged hierarchy, always 
