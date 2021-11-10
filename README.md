# [IrisToolbox] for Macroeconomic Modeling

{== Read me first ==}


## Software dependencies

IrisT runs in [Matlab](https://www.mathworks.com/matlab) R2019b or newer.
There are also legacy releases of IrisT for Matlab R2018a through R2019a
(under the `pre-r2019b` branch) but we strongly discourage using the legacy
codebase. Keep also in mind that some features are not availabe in legacy
releases.

If you want to use the estimation functions for structural `@Model` objects
(not for `@VAR` objects or `@Explanatory` objects) you also need the
Optimization Toolbox installed.


## Getting IrisT installed

You have two options of getting IrisT installed on your computer:

1. Use [Git](https://git-scm.com) to clone the master branch in a
   `irist/folder/of/your/choice` on your computer:

```
git clone https://github.com/IRIS-Solutions-Team/IRIS-Toolbox.git irist/folder/of/your/choice
```

Note that although only the official release are properly tested for bugs,
any pushes to the master branch on this GitHub repository are most of the
time safe to update to.

2. Manually download and unzip [the latest official
   release](https://github.com/IRIS-Solutions-Team/IRIS-Toolbox/releases/tag/Release-20210802)
   into a `irist/folder/of/your/choice/` on your computer.

Of course, replace `irist/folder/of/your/choice/` with a proper path to the
folder where you wish to have IrisT stored locally on your computer. When
unzipping a zip archive, make sure that no nested folder is created, and
that `irist/folder/of/your/choice/` contains, for instance, a file names
`Contents.m`.


## Starting up IrisT in Matlab

Every time you want to start using IrisT in Matlab, run the following
command in the Matlab command prompt:

```
>> addpath irist/folder/of/your/choice; iris.startup
```

where you, of course, need to replace `irist/folder/of/your/choice` with
the proper path you chose when getting IrisT installed on your computer.

Although you could use the **Set Path** dialog in Matlab to put
`irist/folder/of/your/choice` on the Matlab path, we discourage you from
doing that because it may occasionally result in some unwanted side
consequences. Simply type up or invoke the above one line every time you
wish to start up IrisT.

