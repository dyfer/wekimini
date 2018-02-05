//a function that returns an Event, allowing basic communication with an instsance of Wekinator
//requires creating a project in Wekinator first with appropriate number of inputs, outputs, and processing type (continuous out vs dynamic time warp vs classifiers)
//this project will be copied to the directory allProjectsPath as projectID, osc communication will be set up automatically (automatic free port for wekinator's input, sclang's current port for wekinator's output)

/*
//basic usage
~wek = ~makeWekinator.(\dtw_test)
~wek.startWekinator

//check
~wek.numInputs
~wek.numOutputs
~inB = Bus.control(s, 1);
~outB = Bus.control(s, 5);
~wek.inputBus_(~inB)
~wek.outputBus_(~outB)

//start processing
~wek.startStreaming
~wek.stopStreaming

//free
~wek.freeMe; //stops wekinator, frees resources

//test
x = {Out.kr(~inB, PinkNoise.kr())}.play
~outB.scope
~inB.scope
x.free; ~inB.free; ~outB.free;
*/

// ~makeWekinator =
{arg
	projectID/*needs to be unique!*/,
	allProjectsPath = "../wekinator_projects".resolveRelative,
	wekiPath = "../wekinator/WekiMini.jar".resolveRelative,
	wekiSendOscPathPrepend = "/wek/outputs"/*projectID will be added to it*/,
	wekiReceiveOscPath = "/wek/inputs",
	receiveFunc = {},
	inputBus,
	outputBus,
	busReadRate = 50/*Hz*/
	;

	var setElementValue, getElementValue, getNumChildNodes, makeCopy, startWekinator, stopWekinator, checkForFileAndStart, makeCopyDialog, getFreePort, prepareAndStart, startResponder, stopResponder, cleanup;
	var sendMsg, setOutputs, saveProject;
	var setName, setReceivePort, setSendPort, setSendHostname, setSendOscPath, setReceiveOscPath;
	var getNumInputs, getNumOutputs;
	var startStreaming, stopStreaming, streamingRoutine, busReadRateReciprocal, startRunning, stopRunning;
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
		//making dir
		"making dest directory".postln;
		("mkdir" + dstFullPath.escapeChar($ )).postln.unixCmdGetStdOut;
		newProjectFilename = dstProject;
		cmd = "cp -R" + srcPathOnly.escapeChar($ ) + dstFullPath.escapeChar($ );
		cmd.postln;
		"copying...".postln;
		cmd.unixCmdGetStdOut;
		//replace name
		cmd = "mv" + oldProjectFilename.escapeChar($ ) + newProjectFilename.escapeChar($ );
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
		cmd  = "java -jar " ++ wekiPath.escapeChar($ );
		projectPath !? {cmd = cmd + projectPath.escapeChar($ )};
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

	startRunning = {
		var fullMsg = ["/wekinator/control/startRunning"];
		sendNetAddr !? {sendNetAddr.sendMsg(*fullMsg)};
	};

	stopRunning = {
		var fullMsg = ["/wekinator/control/stopRunning"];
		sendNetAddr !? {sendNetAddr.sendMsg(*fullMsg)};
	};

	stopWekinator = {
		var oldPid;
		oldPid = pid;
		{
			(projectID ++ ": stopRunning").postln;
			stopRunning.();
			1.wait;
			(projectID ++ ": saveProject").postln;
			saveProject.();
			5.wait;
			(projectID ++ ": quit Wekinator").postln;
			// {pid !? {("kill" + pid).unixCmd}}.defer(2); ///give time to save the project; 0.5 caused file corruption, increased to 2s!
			oldPid !? {("kill" + oldPid).unixCmd}; //give time to save the project; 0.5 caused file corruption, increased; TEST THIS!
		}.forkIfNeeded;
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
		"path: ".postln; path.postln;
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
		//turn on Wekinator's running
		startRunning.();
		streamingRoutine = Routine.run({
			loop{
				inputBus !? {sendMsg.(*inputBus.getnSynchronous)};
				busReadRateReciprocal.wait;
			};
		});
	};

	stopStreaming = {
		stopRunning.();
		streamingRoutine.stop;
	};

	cleanup = {
		stopWekinator.();
		// stopStreaming.();
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

