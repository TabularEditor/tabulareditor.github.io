---
layout: post
comments: true
title: Power BI Tricks - WhatIf parameters
publish: true
date: 2019-03-14
author: Daniel Otykier
authorurl: http://twitter.com/dotykier
---

**Update May 29th 2019**: It turns out that the technique outlined here can be used for SSAS or Azure Analysis Services Tabular models of Compatibility Level 1400+. In fact, just by adding the `ParameterMetadata` Extended Property (step 9 below) to any numeric column in your model, you can instruct Power BI to display a single-select slider as the default visual for the column.

I received a comment on my [introductory webinar video](https://www.youtube.com/watch?v=HQf55BGUJmk), regarding whether Tabular Editor could be used to generate lots of WhatIf parameters quickly.

Well, behind the scenes, a WhatIf parameter is simply a Calculated Table with a single column, defined using the [GENERATESERIES](https://dax.guide/generateseries) DAX function (to hold all the possible values of the parameter), along with a measure that uses the [SELECTEDVALUE](https://dax.guide/selectedvalue) function to return the currently filtered value on the table (or a default value, if nothing or multiple values are filtered).

### Preparations
All of this can easily be added using Tabular Editor, **although doing it is not officially supported by Microsoft**, so as usual, when modifying your Power BI models through Tabular Editor, make sure to save a backup of your .pbix or .pbit file. By default, Tabular Editor will restrict the kind of changes we can apply to a Power BI model, to prevent things from breaking. However, in order to create WhatIf parameters through Tabular Editor, we need to lift this restriction, as we need to add new Calculated Tables to the model. So make sure to check the "Allow unsupported Power BI features" checkbox under File > Preferences > General:

![image](https://user-images.githubusercontent.com/8976200/54387325-5fa47780-469b-11e9-8071-d766c3a4fd69.png)

As of the March 2019 version of Power BI, connecting Tabular Editor directly to a Power BI model that is loaded within an instance of Power BI Desktop...

![image](https://user-images.githubusercontent.com/8976200/54386273-dee47c00-4698-11e9-9a99-3941f8fab9f2.png)

...does not let us add measures (and possibly other things). We would get an error message similar to the following, when trying to save the model changes:

![image](https://user-images.githubusercontent.com/8976200/54387614-26203c00-469c-11e9-8bb5-ef27915e206c.png)

`Failed to save modifications to the server. Error returned: 'Unexpected column name: Received column 'ObjectID.Expression' in rowset 'ObjectTranslations'. Expected column 'ObjectID.Set'.'.
`

In general when encountering this error, a possible workaround is to export the Power BI model as a template (.pbit file), open the .pbit file within Tabular Editor, reapply the changes and then save the file. When reopening the .pbit file in Power BI Desktop, you may encounter some issues depending on what was changed. In my experience, these can often be overcome by refreshing the data or by simply adding and removing a measure within Power BI Desktop. But not always - hence the **unsupported** warning.

However, for adding WhatIf parameters to a .pbit file with Tabular Editor, if you follow the steps below carefully, you should be good (at least with the March 2019 version of Power BI - who knows what happens in future versions. By the way, if you would like Microsoft to officially support making changes through tools such as Tabular Editor, make sure to give [this idea a vote](https://ideas.powerbi.com/forums/265200-power-bi-ideas/suggestions/7345565-power-bi-designer-api)):

### Let's get to it
1. Export your Power BI model as a template (.pbit file) and close Power BI Desktop
2. Open the .pbit file in Tabular Editor
3. In the "Model" menu, choose "New Calculated Table". Rename the newly added table to whatever you like.
4. Enter the following expression for the newly created Calculated Table: `GENERATESERIES(0, 100, 10)`. Of course, you can change the limits (0 - 100) and increment value (10) to whatever you like.
5. With the Calculated Table still selected go to the "Table" menu and choose "Create New > Calculated Table Column".
6. Rename the newly added calculated table column to whatever you like, but preferably give it the same name as the parent table. Set its Data Type property to "Integer", "Floating Point" or "Currency", depending on your needs.
7. **Important** Set the "Source Column" property of the calculated table column to `[Value]`. This is needed in order to map the output of the calculated table expression into this column.
8. Set the "Summarize By" property on the column to "None", to make sure the values within the column are never aggregated.
9. **Also important** For Power BI to treat the newly added table as a WhatIf parameter, we must add an Extended Property to the calculated table column. Click on the ellipsis button on the "Extended Properties" property of the column, and add a new JsonExtendedProperty. Set the **Name** of this property to `ParameterMetadata` and the **Value** to `{"version":0}`:
 ![image](https://user-images.githubusercontent.com/8976200/54392008-caa77b80-46a6-11e9-956a-e6993fdeaa89.png)

10. Finally, add a measure to the calculated table, to provide the currently selected WhatIf parameter value. This is the measure you're going to use in Power BI, to pull the WhatIf parameter into your WhatIf scenarios. If you named both your calculated table and calculated table column "MyParam", you should name this measure "MyParam Value" and use the expression: `
SELECTEDVALUE('MyParam'[MyParam], 50)` where 50 is the default value to use, in case multiple values/nothing is selected on the WhatIf slicer.
11. Save the .pbit file and close Tabular Editor.
12. Open Power BI Desktop.

Easy peasy, isn't it? No? Well, luckily, there's a much better way to perform the time-consuming steps 3-10.

### Automation for the win!
Paste the following code into Tabular Editors Advanced Scripting tab:

```csharp
// Parameter settings:
var paramName = "MyParam";
var paramMin = 0;
var paramMax = 100;
var paramIncrement = 10;
var paramDefault = 50;
var paramDataType = DataType.Int64;

// Invariant Culture. When used in string.Format, we ensure that decimal numbers are formatted
// with a . (period) as decimal separator, which is the standard way Tabular Editor writes DAX:
var c = System.Globalization.CultureInfo.InvariantCulture; 

// Add a new calculated table to the model:
var table = Model.AddCalculatedTable(paramName, 
    string.Format(c, "GENERATESERIES({0},{1},{2})", paramMin, paramMax, paramIncrement));
    
// Add the Calculated Table column:
var column = table.AddCalculatedTableColumn(paramName, "[Value]", "", paramDataType);
column.SummarizeBy = AggregateFunction.None;

// Set Extended Property on the Calculated Table Column:
column.SetExtendedProperty("ParameterMetadata", "{\"version\":0}", ExtendedPropertyType.Json);

// Add the WhatIf parameter measure:
table.AddMeasure(paramName + " Value", 
    string.Format(c, "SELECTEDVALUE({0}, {1})", column.DaxObjectFullName, paramDefault));
```

To use the script, modify the settings in the top section to suit your needs, and hit F5. That's it. Steps 3-10 completed in a fraction of a second!

### One step further
If you want to get really advanced, you can create a text file containing the settings of multiple WhatIf parameters:

```
MyParam1,0,100,10,50,Int64
MyParam2,100,200,10,150,Int64
MyParam3,-1,1,0.1,0,Double
```

Save this file somewhere on your machine, then modify the script to set the settings based on the contents of this file, and create all 3 parameters in one go:

```csharp
// Modify below to point to the file that holds your WhatIf parameter settings:
var settings = System.IO.File.ReadLines(@"c:\WhatIf\WhatIfSettings.csv");
var c = System.Globalization.CultureInfo.InvariantCulture;

foreach(var setting in settings)
{
    var settingArray = setting.Split(',');
    
    // Parameter settings:
    var paramName = settingArray[0];
    var paramMin = decimal.Parse(settingArray[1],c);
    var paramMax = decimal.Parse(settingArray[2],c);
    var paramIncrement = decimal.Parse(settingArray[3],c);
    var paramDefault = decimal.Parse(settingArray[4],c);
    var paramDataType = (DataType)Enum.Parse(typeof(DataType), settingArray[5]);
    
    // Add a new calculated table to the model:
    var table = Model.AddCalculatedTable(paramName, 
        string.Format(c, "GENERATESERIES({0},{1},{2})", paramMin, paramMax, paramIncrement));
        
    // Add the Calculated Table column and set SummarizeBy to None:
    var column = table.AddCalculatedTableColumn(paramName, "[Value]", "", paramDataType);
    column.SummarizeBy = AggregateFunction.None;

    // Set Extended Property on the Calculated Table Column:
    column.SetExtendedProperty("ParameterMetadata", "{\"version\":0}", ExtendedPropertyType.Json);

    // Add the WhatIf parameter measure:
    table.AddMeasure(paramName + " Value", 
        string.Format(c, "SELECTEDVALUE({0}, {1})", column.DaxObjectFullName, paramDefault));
}
```

After executing the script, save the .pbit file and close Tabular Editor. Then open the file in Power BI Desktop and behold your brand new auto-generated WhatIf parameters!

![image](https://user-images.githubusercontent.com/8976200/54393871-971b2000-46ab-11e9-8069-f3a10f57c664.png)

Feel free to leave comments/feedback/questions below!
