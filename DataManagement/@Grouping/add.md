---
title: add
---

# `add`

{== Add measurement variable group or shock group to Grouping object ==}


## Syntax

    g = add(g, groupName, groupContents)


## Input arguments

* `G` [ Grouping ] - Grouping object.

* `groupName` [ char ] - New group name.

* `groupContents` [ char | cell | `@all` ] - Names of shocks or
measurement variables to be included in the new group; `GroupContents`
can also be regular expressions; `@all` means the group will contain all
shocks or measurement variables not included in any existing group.


## Output arguments

* `G` [ Grouping ] - Grouping object with the new group.


## Description


## Example

