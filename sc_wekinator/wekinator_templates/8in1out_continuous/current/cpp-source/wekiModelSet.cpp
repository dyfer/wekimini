#include <vector>
#include "wekiModelSet.h"

wekiModelSet::wekiModelSet() {
    std::vector<baseModel*> myModelSet;
};

wekiModelSet::~wekiModelSet() {
    for (std::vector<baseModel*>::iterator i = myModelSet.begin(); i != myModelSet.end(); ++i) {
        delete *i;
    }
};

void wekiModelSet::initModelSet() {
   std::vector<int> whichInputs;
   int totalLayers;
   int maxNodes;
   double ***weights;
   double *wHiddenOutput;
   std::vector<double> inMaxes;
   std::vector<double> inMins;
   double outMax;
   double outMin;

    ///////////////////////////////////////////
    //model 0 - neural network
    ///////////////////////////////////////////

    whichInputs.clear();
    whichInputs.push_back(0);
    whichInputs.push_back(1);
    whichInputs.push_back(2);
    whichInputs.push_back(3);
    whichInputs.push_back(4);
    whichInputs.push_back(5);
    whichInputs.push_back(6);
    whichInputs.push_back(7);

    totalLayers = 2;
    maxNodes = 9;
    weights = new double **[totalLayers];
    for (int i = 0; i < totalLayers; ++i) {;
       weights[i] = new double*[maxNodes];
       for (int j = 0; j < maxNodes; ++j) {
           weights[i][j] = new double[maxNodes];
       }
    }
	//weights between input and hidden
}

double* wekiModelSet::passInputToModels(double* input) {
    int setSize = myModelSet.size();
    double* output = new double[setSize];
    for (int i = 0; i < setSize; ++i) {
        output[i] = myModelSet[i]->processInput(input);
    }
    return output;
}