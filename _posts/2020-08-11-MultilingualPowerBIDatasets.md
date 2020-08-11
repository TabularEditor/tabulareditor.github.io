---
layout: post
comments: true
title: Creating Multilingual Power BI Datasets
publish: true
date: 2020-08-11
author: Daniel Otykier
authorurl: http://twitter.com/dotykier
---

## Multilingual Datasets

A little known fact about the Power BI service, is that metadata translations actually work just fine for an imported or DirectQuery dataset within a dedicated capacity workspace (Power BI Premium or A SKUs). You can add metadata translations to a dataset in Premium in two ways: Either [through the XMLA read/write endpoint](https://www.kasperonbi.com/setting-up-translations-for-power-bi-premium/) or by using the [External Tools integration in Power BI Desktop](https://powerbi.microsoft.com/en-us/blog/announcing-public-preview-of-external-tools-in-power-bi-desktop/). This article demonstrates the latter, using Tabular Editor as the external tool.

You can also watch [Christian Wade demonstrate this technique in a video](https://mymbas.microsoft.com/sessions/1165847d-260a-4d28-bec7-6843932e4467) (starting at around 7:00 minutes).

### Prerequisites
Make sure you're using the [July 2020 release (or newer) of Power BI Desktop](https://powerbi.microsoft.com/en-us/desktop/). Also, you'll need to install the [latest version of Tabular Editor](https://github.com/otykier/TabularEditor/releases/latest). I recommend you use the installer, `TabularEditor.installer.msi`. If you used TabularEditor.portable.zip version, you need to manually copy the `TabularEditor.pbitool.json` file from inside the zip file, into your `%commonprogramfiles(x86)%\microsoft shared\Power BI Desktop\External Tools` folder. If that folder doesn't exist, create it!

When launching Power BI Desktop, you should see Tabular Editor on the External Tools ribbon:

![image](https://user-images.githubusercontent.com/8976200/89929656-cd92fc80-dc09-11ea-99e8-eb279db18b74.png)

## Default Model Culture

Before adding metadata translations to your model, make sure the language used for objects in the dataset (tables, columns, measures), is aligned with the Model Language (aka. the Default Model Culture). In Power BI Desktop, under File > Options and Settings > Global Regional Settings, you can see what language will be assigned as the Model Language upon creation of new models:

![image](https://user-images.githubusercontent.com/8976200/89930094-7ccfd380-dc0a-11ea-9945-02da806daf7d.png)

On my machine (see screenshot), this has been set to "Use application language", and since I'm using a US-English version of Power BI Desktop, it means that any new .pbix file I create on my machine, will have its default model culture set to "en-US". This is fine, since I'm always using english names for all my model objects anyway. However, if you installed Power BI Desktop with a different application language, but you still want to use english names (or some other language) for objects in your model, make sure that you adjust the Model Language setting accordingly, **before you create your .pbix file**.

It is not possible to change this setting on an existing .pbix file through Power BI Desktop, but [luckily there is a workaround](https://www.sqlbi.com/articles/changing-the-culture-of-a-power-bi-desktop-file/).

When you open the model in Tabular Editor (by clicking the Tabular Editor button in the External Tools ribbon), you will see that the dataset already includes one Translation object (culture), which should correspond to the Model Language:

![image](https://user-images.githubusercontent.com/8976200/89930673-670ede00-dc0b-11ea-80a8-8e9ed3b9a0cc.png)

Even though this culture exists in the model, it doesn't mean that any objects have actually been translated, and in fact, the point is that for the default model culture, you **should not** apply any translations. If you do, [Power BI Desktop will start to behave weirdly](https://docs.microsoft.com/en-us/power-bi/create-reports/desktop-external-tools#supported-write-operations), with the field list and visuals sometimes showing the translated captions, and other times showing the untranslated names. Hence why you should always make sure that the model language (default model culture) is aligned with the actual names of objects in the model.

## Adding Metadata Translations

To add other languages to your model, simply right-click on the "Translations" folder and choose "New Translation", then, pick the language from the list of cultures.

![image](https://user-images.githubusercontent.com/8976200/89931156-1ba8ff80-dc0c-11ea-90c9-cde105d3608d.png)

Here, I've added a couple of languages to my dataset. At this point, you can safely hit CTRL+S in Tabular Editor, which will synchronize the model metadata in Power BI Desktop to also include these languages, even though we haven't specified any object translations yet.

![image](https://user-images.githubusercontent.com/8976200/89931457-74789800-dc0c-11ea-9f46-c05ce1d69f50.png)

Now, with Tabular Editor there are two ways to define object name translations. The first way, is a "what-you-see-is-what-you-get" sort-of experience, where you pick the language in the dropdown box at the top of the screen. Then, you simply select any object you want to translate in the explorer tree and hit F2 to rename the object. When a language is selected in the dropdown, you are actually creating a translation leaving the physical object name untouched. You can see that the names turn blue to indicate that one or more name translations have been applied to the objects:

![image](https://user-images.githubusercontent.com/8976200/89932387-da195400-dc0d-11ea-8065-6aaba42a1a00.png)

(Unfortunately, due to a bug in Tabular Editor, you can only apply translations to measures this way, unless you enable the "Allow unsupported Power BI features" checkbox under File > Preferences. Metadata translations for other object types are fully supported in Power BI Premium - this is simply a bug in Tabular Editor 2.11.7, which will be fixed in the next release).

You can also apply name translations by going to the "Translated Names" property in the property grid, and typing the translated names across the various model languages. Make sure to leave the default culture (en-US in my case) with a blank translation. Same technique applies in order to translate object descriptions and display folders for measures, columns and hierarchies.

![image](https://user-images.githubusercontent.com/8976200/89932573-22387680-dc0e-11ea-8a97-59e339a45eb0.png)

Alternatively, you can export a .json file from Tabular Editor for use with other tools, such as Kasper de Jonge's [Tabular Translator tool](https://github.com/Kjonge/TabularTranslator/releases/tag/1.1.3). You can export and import translations as JSON by right-clicking on the "Translations" folder annd choosing "Export/Import translations...". However, before you do so, you may want to set up [default translations for all objects in the model](https://tabulareditor.com/2019/10/23/TabularEditorTricks3.html).

## Publishing the dataset

When you're done translating, hit CTRL+S in Tabular Editor to update the model metadata in Power BI Desktop. Then, close Tabular Editor, go back to Power BI Desktop and hit CTRL+S here to save your .pbix file. At this point, the .pbix file contains all the translations you just defined in Tabular Editor, but unfortunately there's no way to observe the translations in Desktop. You can however [test them in Excel](https://www.sqlbi.com/tools/analyze-in-excel-for-power-bi-desktop/) by adding a LocaleIdentifier to the connection string.

The only thing left to do then, is publish the .pbix file to the Power BI service. If you're publishing to a workspace on dedicated capacity (Premium or A-SKUs), you should see translations being correctly observed in the Power BI service on both the dataset field list as well as any report visuals.

