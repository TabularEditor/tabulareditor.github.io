---
layout: post
comments: true
title: Tabular Editor Tricks - Convert to Legacy
publish: true
date: 2019-07-03
author: Daniel Otykier
authorurl: http://twitter.com/dotykier
---

## Converting Power Query partitions to Legacy

When building Analysis Services tabular models on top of a Data Warehouse or Data Mart on a relational database, I recommend using the Legacy (Provider) data sources instead of the Power Query data sources available since SQL Server 2017. Unfortunately, Power Query data sources have become the default in SSDT, and [it has become quite tricky to create Legacy data sources](https://blog.crossjoin.co.uk/2018/01/15/using-your-own-sql-queries-for-tables-with-modern-data-sources-in-ssas-2016-and-azure-analysis-services/) (in short, check "Enable Legacy data sources" under Options > Analysis Services Tabular > Data Import).

There are a couple of reasons for that:

- Refresh performance is similar, but in my experience the Power Query data sources have a small initialisation overhead, which can be annoying if you need to do many frequent, small refreshes.
- You don't want to do any M transformation in your Tabular model partition queries anyway - that's the whole purpose of having an ETL process where data is loaded into a star schema on the relational source.
- When deploying a model or executing a CreateOrReplace TMSL script, credentials used by legacy data sources are not dropped.
- You get to use the sweet [Tabular Editor Import Table wizard](https://github.com/otykier/TabularEditor/wiki/Importing-Tables)

If you already created your model using a Power Query data source and M partitions, here are the steps you need to do, in order to switch to Legacy:

1. Create a Legacy data source on your model and point it to your relational database. Give it a name, for example, "SQLDW".
2. Paste the following script in Tabular Editor's Advanced Scripting tab:
   ```csharp
   var legacy = (Model.DataSources["SQLDW"] as ProviderDataSource);
   
   foreach(var table in Model.Tables)
   {
       table.Partitions.ConvertToLegacy(legacy);
       // foreach(var partition in table.Partitions) partition.Query = "SELECT * FROM " + table.Name;
   }
   ```
3. Before running the script, adjust the name of the data source in line 1, if you provided a different name for the new legacy data source.
4. (Optional) If the names of the imported tables in your model correspond to the names of tables or views in your data source, you can uncomment line 32 to automatically set the query of each partition to a basic `SELECT * FROM <table/view name>`-query.
5. Run the script
6. Go through each partition in your model to verify that the partition is of the correct type (Legacy), and that the partition is using the proper data source. If you skipped step 4, also make sure to enter the proper SQL query on each partition:
   ![image](https://user-images.githubusercontent.com/8976200/60573023-175ab380-9d77-11e9-88bc-1665a686d734.png)
7. Delete your Power Query data source, which should now no longer be in use by any partitions in your model.

And that's it - all partitions on your model are now 100% legacy partitions.
