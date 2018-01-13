//To use Wekinator models, insert the following code into your project

//Wekinator model declaration
#include "wekiModelSet.h"
wekiModelSet trainedModels;

//Wekinator model initialization
trainedModels.initModelSet();

//Wekinator model usage
double* modelOutput = trainedModels.passInputToModels(toModel);
