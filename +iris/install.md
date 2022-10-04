
# Installing and using Iris

## Software dependencies

The official releases on the `stable` branch of the Iris Toolbox run in
[Matlab](https://www.mathworks.com/matlab) R2018a or newer. The `bleeding`
edge branch runs on Matlab R2019b or later.

If you wish to use the estimation functions for structural `@Model` objects
(not for `@VAR` or `@Explanatory` objects) you also need the
Optimization Toolbox installed.


## Getting the Iris Toolbox files

You have two options of getting Iris installed on your computer:


#### Cloning the repository

1. Use [Git](https://git-scm.com) to clone the `stable` branch in a
   `iris/folder/of/your/choice` on your computer:

```
git clone --branch stable https://github.com/IRIS-Solutions-Team/IRIS-Toolbox.git iris/folder/of/your/choice
```

Note that although only the official release are properly tested for bugs,
any pushes to the master branch on this GitHub repository are most of the
time safe to update to.

Alternatively, you can decide to clone the `bleeding` edge branch:

```
git clone https://github.com/IRIS-Solutions-Team/IRIS-Toolbox.git iris/folder/of/your/choice
```


#### Manually downloading and unzippping the release archive 

Unzip 
[the latest official release](https://github.com/IRIS-Solutions-Team/IRIS-Toolbox/releases/latest)
into an `iris/folder/of/your/choice/` on your computer.



## Starting up Iris in Matlab

Every time you want to start using Iris in Matlab, run the following
command in the Matlab command prompt:

```
>> addpath iris/folder/of/your/choice; iris.startup
```

where you, of course, need to replace `iris/folder/of/your/choice` with
the proper path you chose when getting Iris installed on your computer.

Although you could use the **Set Path** dialog in Matlab to put
`iris/folder/of/your/choice` on the Matlab path, we discourage you from
doing that because it may occasionally result in some unwanted side
consequences. Simply type up or invoke the above one line every time you
wish to start up Iris.

