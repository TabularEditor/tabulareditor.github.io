---
layout: post
comments: true
title: Generating a dynamic measure selector
publish: true
date: 2020-08-24
author: Daniel Otykier
authorurl: http://twitter.com/dotykier
---

## Dynamic measure selectors

For certain kinds of reports, it sometimes makes sense to be able to select which measures should be displayed by checking off members on a dimension, rather than including individual measures from the field list. There are many blogs and articles online that describes this pattern in more details. You can find them by searching for [dynamic measure selector switch](https://www.google.com/search?&q=dynamic+measure+selector+switch).

Based on [a question I received on GitHub recently](https://github.com/otykier/TabularEditor/issues/578), this article shows you how to auto-generate a disconnected table for selection together with the SWITCH measure to go along with the table. The technique here used a Tabular Editor script, that is executed while a number of measures are multi-selected in the explorer tree.

## Script

Before executing the script below, you have to decide on a number of things:

1. What would you like the disconnected 1-column selector table to be named?
2. What would you like the column on the disconnected selector table to be named?
3. What would you like to name the dynamic switch measure?
4. On what table should the dynamic switch measure reside?
5. If no filter or more than value is filtered on the selector table, what should the dynamic measure return?

For each question, substitute the strings at the top of the script with the values you decided upon.

```csharp
// (1) Name of disconnected selector table:
var selectorTableName = "Measure Selector";

// (2) Name of column on selector table:
var selectorTableColumnName = "Measure";

// (3) Name of dynamic switch measure:
var dynamicMeasureName = "Dynamic Measure";

// (4) Name of dynamic switch measure's parent table:
var dynamicMeasureTableName = "Measure Selector";

// (5) Fallback DAX expression:
var fallbackDax = "BLANK()";

// ----- Do not modify script below this line -----

if(Selected.Measures.Count == 0) {
    Error("Select one or more measures");
    return;
}

// Get or create selector table:
CalculatedTable selectorTable;
if(!Model.Tables.Contains(selectorTableName)) Model.AddCalculatedTable(selectorTableName);
selectorTable = Model.Tables[selectorTableName] as CalculatedTable;

// Get or create dynamic measure:
Measure dynamicMeasure;
if(!Model.Tables[dynamicMeasureTableName].Measures.Contains(dynamicMeasureName))
    Model.Tables[dynamicMeasureTableName].AddMeasure(dynamicMeasureName);
dynamicMeasure = Model.Tables[dynamicMeasureTableName].Measures[dynamicMeasureName];

// Generate DAX for disconnected table:
// SELECTCOLUMNS({"Measure 1", "Measure 2", ...}, "Measure", [Value])
var selectorTableDax = "SELECTCOLUMNS(\n    {\n        " +
    string.Join(",\n        ", Selected.Measures.Select(m => "\"" + m.Name + "\"").ToArray()) +
    "\n    },\n    \"" + selectorTableColumnName + "\", [Value]\n)";

// Generate DAX for dynamic metric:
// VAR _s = SELECTEDVALUE('Metric Selection'[Value]) RETURN SWITCH(_s, ...)
var dynamicMeasureDax = 
    "VAR _s =\n    SELECTEDVALUE('" + selectorTableName + "'[" + selectorTableColumnName + "])\n" +
    "RETURN\n    SWITCH(\n        _s,\n        " +
    string.Join(",\n        ", Selected.Measures.Select(m => "\"" + m.Name + "\", " + m.DaxObjectFullName).ToArray()) +
    ",\n        " + fallbackDax + "\n    )";

// Assign DAX expressions:
selectorTable.Expression = selectorTableDax;
dynamicMeasure.Expression = dynamicMeasureDax;
```csharp

## Using the script

Simply paste the script into Tabular Editor, select a number of measures in the explorer tree (hold SHIFT or CTRL to multi-select). If your measures are scattered across multiple tables, Tabular Editor will not let you multiselect them (as you cannot select objects from different parts of the tree at once). However, a workaround is to use the filter functionality with search results shown in a flat list (click the button at the very right of the screen). For example, you can put a wildcard `*` in the filter box, or type `:ObjectType = "Measure"` to restrict the search to only show measures.

Once you selected the measures you want to include in the measure selector and the dynamic measure, hit F5 to execute the script. If there was a mistake, you can always hit CTRL+Z to undo the effects of running the script.

For example, if I run the script with this selection of measures:

![image](https://user-images.githubusercontent.com/8976200/91022006-dfef3c00-e5f4-11ea-89f1-98c1253199c9.png)

The script sets the calculated table expression as follows:

![image](https://user-images.githubusercontent.com/8976200/91031887-7a557c80-e601-11ea-988e-3e28d8d69196.png)

...and the dynamic switch measure expression as follows:

![image](https://user-images.githubusercontent.com/8976200/91031937-8ccfb600-e601-11ea-9731-178421543456.png)
