
d.getDocumentElement.getFirstChild.getNodeName

d.getDocumentElement.getElement("projectName").getText.asInteger //get port here!
d.getDocumentElement.getElementsByTagName("projectName").do({ arg tag, index;
	[tag, index].postln;
	tag.dump
	// ( "Sample #" ++ index ++ ", id: " ++ tag.getAttribute("id") ++ ", file: " ++ tag.getText ).postln;
    // DOMElement.getText is an extension to the DOM, if the first child node
    // of an element is a DOMText-node, getText retrieves the string content of it
});



[0].dump

d.getDocumentElement.getChildNodes[0].
.getElement("oscReceivePort").getAttributes

e = d.getDocumentElement.getElement("oscReceivePort").select({|node| node.getNodeType == DOMNode.node_TEXT})[0].setText(6421.asString) //as string is important

e.do({ arg node;
    ("Node: " ++ node.getNodeName ++ " : " ++ node.getNodeValue).postln;
});
.getText.asInteger //get port here!

d.getDocumentElement.getElement("oscReceivePort").setText(6421.asString)

f = File.new("test2/test22.wekproj".resolveRelative, "w");
d.write(f)
f.close

//---prototype

//open

~projectPath = "test3/test3.wekproj".resolveRelative;
d = DOMDocument.new(~projectPath);

d.getDocumentElement.getElement("oscReceivePort").getText.asInteger //get port here!
d.getDocumentElement.getElement("oscReceivePort").select({|node| node.getNodeType == DOMNode.node_TEXT})[0].setText(6421.asString) //as string is important



d.getDocumentElement.getElement("projectName").getText //get port here!
d.getDocumentElement.getElement("projectName").select({|node| node.getNodeType == DOMNode.node_TEXT})[0].setText("newName") //as string is important


//save
f = File.new("test2/test22.wekproj".resolveRelative, "w");
d.write(f)
f.close


//input

~projectPath = "test3/test3.wekproj".resolveRelative;
~projectPath = "test3/".resolveRelative;
~getInputConfigPath = {|projectPath| PathName(projectPath).pathOnly ++ "inputConfig.xml"};
~getOutputConfigPath = {|projectPath| PathName(projectPath).pathOnly ++ "outputConfig.xml"};
~getInputConfigPath.(~projectPath)
~getOutputConfigPath.(~projectPath)
(
~setName = {arg path, newName;
	var domDoc, domDocBackup, file;
	newName = newName.asString;
	domDoc = DOMDocument.new(path);
	domDocBackup = DOMDocument.new(path);
	// domDoc.dump;
	// ~domDoc = domDoc;
	"Current name: ".post;
	domDoc.getDocumentElement.getElement("projectName").getText.postln;
	if(newName.notNil, {
		domDoc.getDocumentElement.getElement("projectName").select({|node| node.getNodeType == DOMNode.node_TEXT})[0].setText(newName);
		"Changed name: ".post;
		domDoc.getDocumentElement.getElement("projectName").getText.postln;
		//save
		"writing file".postln;
		file = File(path, "w");
		domDoc.write(file);
		file.close;
		//check
		"checking backup name: ".post;
		domDocBackup.getDocumentElement.getElement("projectName").getText.postln;
	});
	// c = domDoc;
	// d = domDocBackup;
	domDocBackup; //return backup?
};

~makeProjectCopyName = {arg srcProject,//wekproj file or the folder containing it
	dstPath, //path to copy the whole project folder to
	name //new name
	;
	var srcName, oldName, newName, oldProjectFilename, newProjectFilename, srcPathOnly, dstFullPath, cmd;
	// name = name.asString; //not needed
	srcPathOnly = PathName(srcProject).pathOnly;
	if(srcPathOnly == srcProject, {
		"the same".postln;
		oldName = PathName((srcPathOnly ++ "*.wekproj").pathMatch[0]).fileName; //first wekproj ile
	}, {
		oldName = PathName(srcProject).fileName;
	});
	"oldName: ".post; oldName.postln;
	newName = name ++ ".wekproj";
	dstFullPath = PathName(dstPath).pathOnly ++ name;
	oldProjectFilename = dstFullPath.withTrailingSlash ++ oldName;
	newProjectFilename = dstFullPath.withTrailingSlash ++ newName;
	cmd = "cp -R" + srcPathOnly + dstFullPath;
	// cmd.postln;
	"copying...".postln;
	cmd.unixCmdGetStdOut;
	//replace name
	cmd = "mv" + oldProjectFilename + newProjectFilename;
	"renaming file...".postln;
	cmd.postln;
	cmd.unixCmdGetStdOut;
	{~setName.(newProjectFilename, name); "new name set".postln;}.defer(1);
};

~setOutPort = {arg path, newPort;
	var domDoc, domDocBackup, file;
	domDoc = DOMDocument.new(path);
	domDocBackup = DOMDocument.new(path);
	"Current port: ".post;
	domDoc.getDocumentElement.getElement("oscReceivePort").getText.postln;
	if(newPort.notNil, {
		domDoc.getDocumentElement.getElement("oscReceivePort").select({|node| node.getNodeType == DOMNode.node_TEXT})[0].setText(newPort.asString);
		"Changed port: ".post;
		domDoc.getDocumentElement.getElement("oscReceivePort").getText.postln;
		//save
		"writing file".postln;
		file = File(path, "w");
		domDoc.write(file);
		file.close;
		//check
		"checking backup port: ".post;
		domDocBackup.getDocumentElement.getElement("oscReceivePort").getText.postln;
	});
	domDocBackup; //return backup?
};


~startWekinator = {arg projectPath, wekiPath = "../wekinator/WekiMini.jar".resolveRelative;
	var cmd;
	// ~wekiJarPath =
	cmd  = "java -jar " ++ wekiPath;
	projectPath !? {cmd = cmd + projectPath};
	cmd.unixCmd;
	// ~projectPath = "test3/test3.wekproj".resolveRelative;
}

)
// ~setName.("/Volumes/data/Dokumenty/2017-2018/wekinator/sc_tests/newName2/newName2.wekproj", \nowy.asString)
// ~domDoc.getDocumentElement
~makeProjectCopyName.(~projectPath, "/Volumes/data/Dokumenty/2017-2018/wekinator/sc_tests/", \newName2)

PathName(~projectPath).pathOnly ++ "outputConfig.xml"
PathName(~projectPath).pathOnly ++ "inputConfig.xml"
PathName(~projectPath).pathOnly ++ "inputConfig.xml"

~path = "/Volumes/data/Dokumenty/2017-2018/wekinator/sc_tests/newName2/"; ~new = PathName(~path).pathOnly ++ (PathName(PathName(~path).pathOnly).folderName++".wekproj");

~setOutPort.(~new, rrand(8000, 80000))

~startWekinator.(~new)

"kill 96701".unixCmd



File.copy(PathName(~projectPath).pathOnly, "/Volumes/data/Dokumenty/2017-2018/wekinator/sc_tests/new/")

File.copy("/Volumes/data/Dokumenty/2017-2018/wekinator/sc_tests/test3/test3.wekproj", "/Volumes/data/Dokumenty/2017-2018/wekinator/sc_tests/test3/test4.wekproj")

(
~getName = {|path, newName = ""|
	var domDoc;
	domDoc = DOMDocument.new(path);
	// "Current name: ".post;
	domDoc.getDocumentElement.getElement("projectName").getText;
}
)



~setName.(~projectPath, "teasdasdasd")
~setName.(~projectPath)
~getName.(~projectPath)


PathName(~projectPath).pathOnly ++ "outputConfig.xml"
PathName(~projectPath).pathOnly ++ "inputConfig.xml"
Fil

//open wekinator
(
"".resolveRelative
~wekiJarPath = "../wekinator/WekiMini.jar".resolveRelative;
~cmd  ="java -jar " ++ ~wekiJarPath;
~projectPath = "test3/test3.wekproj".resolveRelative;
~projectPath !? {~cmd = ~cmd + ~projectPath};
~pid = ~cmd.unixCmd
~pid.kill

KillPid
"".sss

//desired SC interface:
//copy/rename example project: 1. folder name, 2. project name, 3. projectName in xml file
//File.copy

//at runtime:
//change receive port
//change sending port
//maybe change sending path?
//maybe check number inputs outputs?

//on runtime - open defined path, and if not found, then use opendialog to specify template to copy from?

//all other paramters set manually for now....