---
layout: post
comments: true
title: Tabular Editor Tricks - Object State
publish: true
date: 2019-03-26
author: Daniel Otykier
authorurl: http://twitter.com/dotykier
---

If you're refreshing different parts of your Tabular Model at different times of the day, you may need to know what the current refresh state is, across all objects of the model. For example, running a "dataOnly" refresh on a table, does not automatically refresh calculated columns, hierarchies or relationships.

To know which objects are not in a "Ready" state, simply open Tabular Editor, load the model from your Analysis Services instance, and write the following in the Filter textbox at the top right corner of the screen:

```
:State<>"Ready"
```

Make sure to toggle the "Flat list" search result option (the right-most button on the toolbar). This should produce a result like the following:

![image](https://user-images.githubusercontent.com/8976200/55004159-fe08d500-4fd9-11e9-9558-bc6757d8c330.png)

In general, the Filter text box can be used to search across all object properties using [Dynamic LINQ syntax](https://github.com/kahanu/System.Linq.Dynamic/wiki/Dynamic-Expressions). To enable [Dynamic LINQ Filtering in Tabular Editor](https://github.com/otykier/TabularEditor/wiki/Advanced-Filtering-of-the-Explorer-Tree), make sure to put a colon (:) at the front of your search query.
