# CoverageBrowser
Simulation based coverage testing for Pharo

## How to load

```smalltalk
Metacello new
  baseline: 'CoverageBrowser';
  repository: 'github://bauing-schmidt/CoverageBrowser/src';
  load.
 ```

## How to run

```smalltalk
CoverageBrowser new open
 ```

This is just a raw sketch. You probably want to create own subclass with different `suite` and `methods` definition.
