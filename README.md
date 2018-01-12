# wekimini
This is the "mini" version of the new Wekinator, first released Spring 2015.

All code by Rebecca Fiebrink, except for included libraries (see licenses) and
WeakListenerSupport.java (see header for full attribution).

www.wekinator.org

## Building

Make sure you have Java, Java SDK, and Ant installed, then:

```
ant -f build.xml -Dplatforms.JDK_1.7.home="%JAVA_HOME%"
```
OSX: if JAVA_HOME is not set, it should probably be `/Library/Java/Home`
```
ant -f build.xml -Dplatforms.JDK_1.7.home=/Library/Java/Home
```

## Running

The following command opens a new Wekinator project.

```
java -jar dist/WekiMini.jar
```

This is a fork using a commit from another [fork](https://github.com/brannondorsey/wekimini) of the Wekinator Project, that adds the functionality to open Wekinator projects from the command line.

To open an existing Wekinator project and immediately begin listening on the OSC port specified
in its .wekproj file simply add the path to the project file as a command line argument. Multiple
projects can be opened in this way.

```
java -jar dist/WekiMini.jar /path/to/wek/project.wekproj /path/to/another/project.wekproj
```

## Controlling Wekinator via OSC messages

Please refer to <http://www.wekinator.org/detailed-instructions/#Controlling_Wekinator_via_OSC_messages>.

Additionally, this fork allows:

* __/wekinator/control/saveProject__ (no arguments): Save the current project (equivalent of selecting File -> Save). Project needs to be either opened or saved as first.
