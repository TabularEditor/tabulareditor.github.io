---
layout: post
comments: true
title: Tabular Editor Tricks - Apply Default Translations
publish: true
date: 2019-10-23
author: Daniel Otykier
authorurl: http://twitter.com/dotykier
---

## Exporting Translations

Tabular Editor lets you export translations into the same .json file format used by Visual Studio and [SSAS Tabular Translator](https://www.sqlbi.com/tools/ssas-tabular-translator/). This is useful if you want to delegate the task of translating your model to someone without access to your tabular model metadata. Let's say you've added a new culture (called "translation" within Tabular Editor) to your model, and exported it to .json, without having translated anything yet within Tabular Editor:

![image](https://user-images.githubusercontent.com/8976200/67419241-a6ad0080-f5cc-11e9-8ef3-a2a7c9d6cbfd.png)

The .json file will have the following structure:

![image](https://user-images.githubusercontent.com/8976200/67419742-8e89b100-f5cd-11e9-91d2-db3245c37963.png)

The first section ("referenceCulture"), specifies the physical names of all translatable objects within the tabular object model tree. The second section ("cultures"), holds a single object representing the translation that we exported through the UI. Unfortunately, as you can see on the screenshot above, this object does not hold anything other than the name of the culture (in this case, "da-DK"). The person who's going to supply the translations, will have a hard time figuring out what to do with this file, since there's no obvious place to enter the translated names. They would have to know about the json schema of these translation files, and fill out everything accordingly - quite a daunting task.

To provide a file that is easier to work with, let's use Tabular Editor's Advanced Scripting functionality, to apply a default translation to all objects that are not yet translated. Simply execute the following script, before exporting the translation:

```c#
// Loop through all cultures in the model:
foreach(var culture in Model.Cultures)
{
    // Loop through all objects in the model, that are translatable:
    foreach(var obj in Model.GetChildrenRecursive(true).OfType<ITranslatableObject>())
    {
        // Assign a default translation based on the object name, if a translation has not already been assigned:
        if(string.IsNullOrEmpty(obj.TranslatedNames[culture]))
            obj.TranslatedNames[culture] = obj.Name;

        // Assign a default description based on the object description, if a translation has not already been assigned:
        if(string.IsNullOrEmpty(obj.TranslatedDescriptions[culture]))
            obj.TranslatedDescriptions[culture] = ((IDescriptionObject)obj).Description;
        
        // If the object resides in a display folder, make sure we provide a default translation for the folder as well:
        if(obj is IFolderObject)
        {
            var fObj = obj as IFolderObject;
            if(string.IsNullOrEmpty(fObj.TranslatedDisplayFolders[culture]))
                fObj.TranslatedDisplayFolders[culture] = fObj.DisplayFolder;
        }
    }
}
```

By doing this, we're using each objects physical name as its translated name, unless a translation was already present.

Now, when exporting the translation to a .json file again, it will look like this:

![image](https://user-images.githubusercontent.com/8976200/67422517-eecf2180-f5d2-11e9-9af5-a66026f7b82e.png)

Ahh - much better! Instruct your translator to edit all the "translatedCaption" strings and hand the file back to you. That's it!
