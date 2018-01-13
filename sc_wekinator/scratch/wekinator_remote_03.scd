

d = DOMDocument("newName/newName.wekproj".resolveRelative);
d = DOMDocument("newName/outputConfig.xml".resolveRelative);

d.getDocumentElement.getElement("outputs").getChildNodes.size //numOutputs

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
NetAddr

(
~createWekinatorObject = {arg projectID/*needs to be unique!*/, allProjectsPath = "../wekinator_projects".resolveRelative, wekiPath = "../wekinator/WekiMini.jar".resolveRelative, wekiSendOscPathPrepend = "/wek/outputs"/*projectID will be added to it*/, wekiReceiveOscPath = "/wek/inputs", receiveFunc = {}, inputBus, outputBus, busReadRate = 50/*Hz*/; //also needed: wekiPort,

	var setElementValue, getElementValue, getNumChildNodes, makeCopy, startWekinator, stopWekinator, checkForFileAndStart, makeCopyDialog, getFreePort, prepareAndStart, startResponder, stopResponder, cleanup;
	var sendMsg, setOutputs, saveProject;
	var setName, setReceivePort, setSendPort, setSendHostname, setSendOscPath, setReceiveOscPath;
	var getNumInputs, getNumOutputs;
	var startStreaming, stopStreaming, streamingRoutine, busReadRateReciprocal;
	var projectPath, outputConfigPath, inputConfigPath;
	var projectFileExists = false, wekinatorIsRunning = false;
	var wekiSendOscPathFull;
	var pid, wekinatorPort, sendNetAddr, responder;
	var numInputs, numOutputs; //to/from Wekinator

	//wekinator
	//receive port is set automatically, send port is set to SCLang's
	//receive OSC path is set from arguments
	//send OSC path is set to wekiSendOscPathPrepend/projectID
	//dynamic time warping is implemented to read the probabilities, but not trigger "recognized" action above threshold

	projectID = projectID.asString;
	projectPath = allProjectsPath.withTrailingSlash ++ projectID.withTrailingSlash ++ projectID ++ ".wekproj";
	outputConfigPath = allProjectsPath.withTrailingSlash ++ projectID.withTrailingSlash ++ "outputConfig.xml";
	inputConfigPath = allProjectsPath.withTrailingSlash ++ projectID.withTrailingSlash  ++ "inputConfig.xml";

	wekiSendOscPathFull = wekiSendOscPathPrepend.withTrailingSlash ++ projectID;

	busReadRateReciprocal = busReadRate.reciprocal;

	setElementValue = {arg path, elementTagName, newValue;
		var domDoc, domDocBackup, file, currentValue;
		domDoc = DOMDocument.new(path);
		// domDocBackup = DOMDocument.new(path);
		// domDoc.dump;
		// ~domDoc = domDoc;
		newValue = newValue.asString;
		("Current " ++ elementTagName ++ ": ").post;
		currentValue = domDoc.getDocumentElement.getElement(elementTagName).getText.postln;
		// a = currentValue;
		// b = newValue;
		if((newValue != currentValue) && newValue.notNil, {
			domDoc.getDocumentElement.getElement(elementTagName).select({|node| node.getNodeType == DOMNode.node_TEXT})[0].setText(newValue);
			("Changed " ++ elementTagName ++ ": ").post;
			domDoc.getDocumentElement.getElement(elementTagName).getText.postln;
			//save
			// "writing file".postln;
			file = File(path, "w");
			domDoc.write(file);
			file.close;
			//check
			// "checking backup name: ".post;
			// domDocBackup.getDocumentElement.getElement(elementTagName).getText.postln;
		}, {
			// "Not changing".postln;
			// ("Not changing. Current value: " ++ currentValue ++ ", new value: " ++ newValue).postln;
		});
		// domDocBackup; //return backup?
	};

	getElementValue = {arg path, elementTagName;
		var domDoc, domDocBackup, file, currentValue;
		domDoc = DOMDocument.new(path);
		// ("Current " ++ elementTagName ++ ": ").post;
		currentValue = domDoc.getDocumentElement.getElement(elementTagName).getText;//.postln;
	};

	getNumChildNodes = {arg path, elementTagName;
		var domDoc, domDocBackup, file, currentValue;
		domDoc = DOMDocument.new(path);
		currentValue = domDoc.getDocumentElement.getElement(elementTagName).getChildNodes.size;
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

	getNumInputs = {
		"num inputs: ".post;
		numInputs = getElementValue.(inputConfigPath, "numInputs").asInteger.postln;
	};

	getNumOutputs= {
		var numGestures;
		try {
			numGestures = getElementValue.(outputConfigPath, "numGestures").asInteger;
		};
		if(numGestures.notNil, {
			numOutputs = numGestures;
		}, {
			numOutputs = getNumChildNodes.(outputConfigPath, "outputs");
		});
		"num outputs: ".post;
		numOutputs.postln;
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
		getNumInputs.();
		getNumOutputs.();
		startResponder.();
		startWekinator.({stopResponder.(); sendNetAddr = nil;});
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
		// stopWekinator.();
		// "pid: ".post; pid.postln;
		if(pid.isNil, {
			pid = cmd.unixCmd({|res, pidArg| wekinatorIsRunning = false; pid = nil; onClose.(res, pidArg)}, true);
			"wekinator started, pid: ".post; pid.postln;
			wekinatorIsRunning = true;
		}, {
			"pid is ".post; pid.post; ", not starting".postln;
		});
	};

	sendMsg = {arg ...msg; //values only
		var fullMsg = [wekiReceiveOscPath] ++ msg;
		// fullMsg.postln;
		sendNetAddr !? {sendNetAddr.sendMsg(*fullMsg)};
	};

	setOutputs = {arg values = [];
		var fullMsg = ["/wekinator/control/outputs"] ++ values;
		sendNetAddr !? {sendNetAddr.sendMsg(*fullMsg)};
	};

	saveProject = {
		var fullMsg = ["/wekinator/control/saveProject"];
		sendNetAddr !? {sendNetAddr.sendMsg(*fullMsg)};
	};

	stopWekinator = {
		saveProject.();
		{pid !? {("kill" + pid).unixCmd}}.defer(0.5); ///give time to save the project
	};

	makeCopyDialog = {
		var msg = projectID ++ ": choose the folder to be copied conatining .wekproj file; inputBus.numChannels is " ++ inputBus.numChannels ++ ", outputBus.numChannels is " ++ outputBus.numChannels;
		msg.postln;
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
			makeCopyDialog.(); //this will call this function again
			//if open wekinator, then start wekinator, add opendialog to onclose
			//if not, choose opendialog
			//after opendialog, start wekinator
		});
	};

	startResponder = {
		responder = OSCFunc({|msg|
			var values = msg[1..];
			// msg.postln;
			receiveFunc.(values);
			outputBus !? {outputBus.setnSynchronous(values)};
		}, wekiSendOscPathFull);
	};

	stopResponder = {
		responder.free;
	};

	startStreaming = {
		streamingRoutine !? {streamingRoutine.stop};
		//check for number of inputs/outputs
		inputBus !? {
			var numChannels = inputBus.numChannels;
			if(numChannels != numInputs, {
				var msg = projectID ++ ": number of inputs (" ++ numInputs.asString ++ ") doesn't match number of channels of the inputBus (" ++ numChannels ++ ")";
				msg.warn; //or throw error instead?
			});
		};
		outputBus !? {
			var numChannels = outputBus.numChannels;
			if(numChannels != numOutputs, {
				var msg = projectID ++ ": number of outputs (" ++ numOutputs.asString ++ ") doesn't match number of channels of the outputBus (" ++ numChannels ++ ")";
				msg.warn; //or throw error instead?
			});
		};
		streamingRoutine = Routine.run({
			loop{
				inputBus !? {sendMsg.(*inputBus.getnSynchronous)};
				busReadRateReciprocal.wait;
			};
		});
	};

	stopStreaming = {
		streamingRoutine.stop;
	};

	cleanup = {
		stopWekinator.();
		stopStreaming .();
		stopResponder.();
	};

	(
		// projectPath_: {|self, path| }
		startWekinator: {checkForFileAndStart.()},
		freeMe: {cleanup.()},
		sendMsg: {|self, args| sendMsg.(*args)}, //values only, as an array; or use a bus
		receiveFunc: receiveFunc,
		receiveFunc_: {|self, newFunc| receiveFunc = newFunc},
		busReadRate_: {|self, val| busReadRate = val; busReadRateReciprocal = busReadRate.reciprocal;},
		inputBus_: {|self, bus| inputBus = bus}, //add check for number of channels?
		outputBus_: {|self, bus| outputBus = bus}, //add check for number of channels?
		startStreaming: {startStreaming.()},
		stopStreaming: {stopStreaming.()},
		numInputs: {numInputs},
		numOutputs: {numOutputs},
		saveProject: {saveProject.()}
	)
};
)

~wek = ~createWekinatorObject.(\dtw_test)
~wek.startWekinator
~wek.saveProject;
NetAddr("localhost", 53689).sendMsg("/wekinator/control/saveProject")
~wek.numInputs
~wek.numOutputs
~wek.freeMe;


~inB = Bus.control(s, 5);
~outB = Bus.control(s, 5);
~wek.inputBus_(~inB)
~wek.outputBus_(~outB)
~wek.startStreaming
~wek

//seems to work
//posibly check if there's option to save from osc

~outB.scope
NetAddr("localhost", 57055).sendMsg("/wekinator/control/stopRunning")

(
r.stop;
r = Routine.run({
	loop{
		~wek.sendMsg([rrand(0.5, 0.9);]);
		0.1.wait;
	}
})
)


~wek

~wek.receiveFunc_({|args| args.postln;})
~wek.sendMsg([1,2,3, 4, 5])

~weks = 11.collect({|inc| ~createWekinatorObject.(\newProj_ ++ inc)});
~weks.do({|thisWek| thisWek.startWekinator});
~weks.do(_.freeMe);

~makeProjectCopyName.(~projectPath, "/Volumes/data/Dokumenty/2017-2018/wekinator/sc_tests/", \newName2)


PathName(~projectPath).pathOnly ++ "outputConfig.xml"
PathName(~projectPath).pathOnly ++ "inputConfig.xml"
PathName(~projectPath).pathOnly ++ "inputConfig.xml"

~path = "/Volumes/data/Dokumenty/2017-2018/wekinator/sc_tests/newName2/"; ~new = PathName(~path).pathOnly ++ (PathName(PathName(~path).pathOnly).folderName++".wekproj");

s.boot
b = Bus.control(s, 8)
b.getnSynchronous
b.setnSynchronous([1, 33, 4])