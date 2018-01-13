
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
~createWekinatorObject = {arg projectID/*needs to be unique!*/, allProjectsPath = "../wekinator_projects".resolveRelative, wekiPath = "../wekinator/WekiMini.jar".resolveRelative, wekiSendOscPathPrepend = "/wek/outputs"/*projectID will be added to it*/, wekiReceiveOscPath = "/wek/inputs"; //also needed: wekiPort,

	var setElementValue, makeCopy, startWekinator, stopWekinator, checkForFileAndStart, makeCopyDialog, getFreePort, sendMsg, prepareAndStart, startResponder, stopResponder, cleanup;
	var setName, setReceivePort, setSendPort, setSendHostname, setSendOscPath, setReceiveOscPath;
	var projectPath, outputConfigPath, inputConfigPath;
	var projectFileExists = false, wekinatorIsRunning = false;
	var wekiSendOscPathFull;
	var pid, wekinatorPort, sendNetAddr, responder, incomingDataFunc = {};

	//wekinator
	//receive port is set automatically, send port is set to SCLang's
	//receive OSC path is set from arguments
	//send OSC path is set to wekiSendOscPathPrepend/projectID

	projectID = projectID.asString;
	projectPath = allProjectsPath.withTrailingSlash ++ projectID.withTrailingSlash ++ projectID ++ ".wekproj";
	outputConfigPath = allProjectsPath.withTrailingSlash ++ projectID.withTrailingSlash ++ "outputConfig.xml";
	inputConfigPath = allProjectsPath.withTrailingSlash ++ projectID.withTrailingSlash  ++ "inputConfig.xml";

	wekiSendOscPathFull = wekiSendOscPathPrepend.withTrailingSlash ++ projectID;

	setElementValue = {arg path, elementTagName, newValue;
		var domDoc, domDocBackup, file, currentValue;
		domDoc = DOMDocument.new(path);
		// domDocBackup = DOMDocument.new(path);
		// domDoc.dump;
		// ~domDoc = domDoc;
		newValue = newValue.asString;
		("Current " ++ elementTagName ++ ": ").post;
		currentValue = domDoc.getDocumentElement.getElement(elementTagName).getText.postln;
		a = currentValue;
		b = newValue;
		if((newValue != currentValue) && newValue.notNil, {
			domDoc.getDocumentElement.getElement(elementTagName).select({|node| node.getNodeType == DOMNode.node_TEXT})[0].setText(newValue);
			("Changed " ++ elementTagName ++ ": ").post;
			domDoc.getDocumentElement.getElement(elementTagName).getText.postln;
			//save
			"writing file".postln;
			file = File(path, "w");
			domDoc.write(file);
			file.close;
			//check
			// "checking backup name: ".post;
			// domDocBackup.getDocumentElement.getElement(elementTagName).getText.postln;
		}, {
			"Not changing".postln;
			// ("Not changing. Current value: " ++ currentValue ++ ", new value: " ++ newValue).postln;
		});
		// domDocBackup; //return backup?
	};
	setName = {arg newName; //assumes knowing project path
		newName !? {setElementValue.(projectPath, "projectName", newName)};
	};

	setReceivePort = {arg newPort;
		newPort !? {setElementValue.(projectPath, "oscReceivePort", newPort.asString)};
	};

	setSendPort = {arg newPort;
		newPort !? {setElementValue.(outputConfigPath, "outputPort", newPort.asString)};
	};

	setSendHostname = {arg newHostname;
		newHostname !? {setElementValue.(outputConfigPath, "hostName", newHostname.asString)};
	};

	setSendOscPath = {arg newPath; // /wek/outputs
		newPath !? {setElementValue.(outputConfigPath, "oscMessage", newPath.asString)};
	};

	setReceiveOscPath = {arg newPath; // /wek/inputs
		newPath !? {setElementValue.(inputConfigPath, "oscMessage", newPath.asString)};
	};

	makeCopy = {arg srcProject,//wekproj file
		// dstPath, //path to copy the whole project folder to
		dstProject //wekproj file
		// name //new name - will be inferred
		;
		var srcName, oldName, newName, oldProjectFilename, newProjectFilename, srcPathOnly, dstFullPath, cmd, name;
		name = PathName(dstProject).fileNameWithoutExtension;
		// "name: ".post; name.postln;
		srcPathOnly = PathName(srcProject).pathOnly;
		if(srcPathOnly == srcProject, {
			"the same".postln;
			oldName = PathName((srcPathOnly ++ "*.wekproj").pathMatch[0]).fileName; //first wekproj ile
		}, {
			oldName = PathName(srcProject).fileName;
		});
		"oldName: ".post; oldName.postln;
		// newName = name ++ ".wekproj";
		dstFullPath = PathName(dstProject).pathOnly;//
		oldProjectFilename = dstFullPath.withTrailingSlash ++ oldName; //after copying
		// newProjectFilename = dstFullPath.withTrailingSlash ++ newName;
		newProjectFilename = dstProject;
		cmd = "cp -R" + srcPathOnly + dstFullPath;
		cmd.postln;
		"copying...".postln;
		cmd.unixCmdGetStdOut;
		//replace name
		cmd = "mv" + oldProjectFilename + newProjectFilename;
		"renaming file...".postln;
		cmd.postln;
		cmd.unixCmdGetStdOut;
		// {~setName.(newProjectFilename, name); "new name set".postln;}.defer(1);
		setName.(name);
	};

	getFreePort = {
		//from "https://unix.stackexchange.com/questions/55913/whats-the-easiest-way-to-find-an-unused-local-port"
		"python -c 'import socket; s=socket.socket(); s.bind((\"\", 0)); print(s.getsockname()[1]); s.close()'".unixCmdGetStdOut.asInteger;
	};

	prepareAndStart = {
		wekinatorPort = getFreePort.();
		sendNetAddr = NetAddr("localhost", wekinatorPort);
		setReceivePort.(wekinatorPort);
		setSendPort.(NetAddr.langPort);
		// setSendHostname.("localhost"); //localhost by default... not needed for now?
		setSendOscPath.(wekiSendOscPathFull);
		setReceiveOscPath.(wekiReceiveOscPath);
		startResponder.();
		startWekinator.({stopResponder.()});
	};

	// startWekinator = {arg wPath, pPath, onClose = {};
	// 	var cmd;
	// 	cmd  = "java -jar " ++ wPath;
	// 	pPath !? {cmd = cmd + pPath};
	// 	pid = cmd.unixCmd({|res, pid| wekinatorIsRunning = false; pid = nil; onClose.(res, pid)}, true);
	// 	// pid = cmd.unixCmd(onClose, true);
	// 	wekinatorIsRunning = true;
	// };

	startWekinator = {arg onClose = {};
		var cmd;
		cmd  = "java -jar " ++ wekiPath;
		projectPath !? {cmd = cmd + projectPath};
		cmd.postln;
		//kill old one
		stopWekinator.();
		pid = cmd.unixCmd({|res, pid| wekinatorIsRunning = false; pid = nil; onClose.(res, pid)}, true);
		// pid = cmd.unixCmd(onClose, true);
		wekinatorIsRunning = true;
	};

	sendMsg = {arg ...msg;
		sendNetAddr !? {sendNetAddr.sendMsg(*msg)};
	};

	stopWekinator = {
		pid !? {("kill" + pid).unixCmd};
	};

	makeCopyDialog = {
		var msg = "choose the folder to be copied conatining .wekproj file for " ++ projectID;
		msg.postln;
		// File.openDialog(msg, {|chosenPath|
		// 	if(PathName(chosenPath).extension == "wekproj", {
		// 		makeCopy.(chosenPath, projectPath);
		// 		}, {
		// 			"this path doesn't seem to be a .wekproj file:".warn;
		// 			chosenPath.postln;
		// 	});
		// 	checkForFileAndStart.(projectPath); //loop?
		// 	}, {
		// 		("no file chosen for " ++ projectID).postln;
		// });
		FileDialog({|chosenPaths|
			var chosenPath = (chosenPaths[0].withTrailingSlash ++ "*.wekproj").pathMatch[0];
			"chosenPath: ".post; chosenPath.postln;
			if(chosenPath.notNil, {
				makeCopy.(chosenPath, projectPath);
			}, {
				"this folder doesn't seem to contain a .wekproj file:".warn;
				chosenPaths.postln;
			});
			checkForFileAndStart.(projectPath); //loop?
		}, {
			("no file chosen for " ++ projectID).postln;
		},
		2, //folders
		0 //open
		);
	};

	checkForFileAndStart = {//arg path; //proceed accordingly here
		var path = projectPath;
		// "path: ".postln; path.postln;
		if(File.exists(path), {
			projectFileExists = true;
			//set ports, paths?
			//check num i/o?
			//start Wekinator
			prepareAndStart.();
		}, {
			projectFileExists = false;
			//openfialog to choose file to copy? or dialog asking if one should open new Wekinator project or start a new one?
			makeCopyDialog.();
			//if open wekinator, then start wekinator, add opendialog to onclose
			//if not, choose opendialog
			//after opendialog, start wekinator
			// prepareAndStart.();
		});
	};

	startResponder = {
		responder = OSCFunc({|msg|
			msg.postln;
			incomingDataFunc.(msg); //needs to change I think
		}, wekiSendOscPathFull);
	};

	stopResponder = {
		responder.free;
	};

	cleanup = {
		stopWekinator.();
		stopResponder.();
	};

	(
		// projectPath_: {|self, path| }
		startWekinator: {checkForFileAndStart.()},
		freeMe: {cleanup.()};
	)
}
)

~wek = ~createWekinatorObject.(\newProj23)
~wek.startWekinator
~wek.freeMe;

~weks = 11.collect({|inc| ~createWekinatorObject.(\newProj_ ++ inc)});
~weks.do({|thisWek| thisWek.startWekinator});
~weks.do(_.freeMe);

	NetAddr("localhost", 57120).sendMsg('/test', 2)
	NetAddr.langPort
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