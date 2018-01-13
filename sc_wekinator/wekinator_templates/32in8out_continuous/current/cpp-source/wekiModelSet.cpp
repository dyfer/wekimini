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
    whichInputs.push_back(8);
    whichInputs.push_back(9);
    whichInputs.push_back(10);
    whichInputs.push_back(11);
    whichInputs.push_back(12);
    whichInputs.push_back(13);
    whichInputs.push_back(14);
    whichInputs.push_back(15);
    whichInputs.push_back(16);
    whichInputs.push_back(17);
    whichInputs.push_back(18);
    whichInputs.push_back(19);
    whichInputs.push_back(20);
    whichInputs.push_back(21);
    whichInputs.push_back(22);
    whichInputs.push_back(23);
    whichInputs.push_back(24);
    whichInputs.push_back(25);
    whichInputs.push_back(26);
    whichInputs.push_back(27);
    whichInputs.push_back(28);
    whichInputs.push_back(29);
    whichInputs.push_back(30);
    whichInputs.push_back(31);

    totalLayers = 2;
    maxNodes = 33;
    weights = new double **[totalLayers];
    for (int i = 0; i < totalLayers; ++i) {;
       weights[i] = new double*[maxNodes];
       for (int j = 0; j < maxNodes; ++j) {
           weights[i][j] = new double[maxNodes];
       }
    }
	//weights between input and hidden
    ///////////////////////////////////////////
    //model 1 - neural network
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
    whichInputs.push_back(8);
    whichInputs.push_back(9);
    whichInputs.push_back(10);
    whichInputs.push_back(11);
    whichInputs.push_back(12);
    whichInputs.push_back(13);
    whichInputs.push_back(14);
    whichInputs.push_back(15);
    whichInputs.push_back(16);
    whichInputs.push_back(17);
    whichInputs.push_back(18);
    whichInputs.push_back(19);
    whichInputs.push_back(20);
    whichInputs.push_back(21);
    whichInputs.push_back(22);
    whichInputs.push_back(23);
    whichInputs.push_back(24);
    whichInputs.push_back(25);
    whichInputs.push_back(26);
    whichInputs.push_back(27);
    whichInputs.push_back(28);
    whichInputs.push_back(29);
    whichInputs.push_back(30);
    whichInputs.push_back(31);

    totalLayers = 2;
    maxNodes = 33;
    weights = new double **[totalLayers];
    for (int i = 0; i < totalLayers; ++i) {;
       weights[i] = new double*[maxNodes];
       for (int j = 0; j < maxNodes; ++j) {
           weights[i][j] = new double[maxNodes];
       }
    }
	//weights between input and hidden
    ///////////////////////////////////////////
    //model 2 - neural network
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
    whichInputs.push_back(8);
    whichInputs.push_back(9);
    whichInputs.push_back(10);
    whichInputs.push_back(11);
    whichInputs.push_back(12);
    whichInputs.push_back(13);
    whichInputs.push_back(14);
    whichInputs.push_back(15);
    whichInputs.push_back(16);
    whichInputs.push_back(17);
    whichInputs.push_back(18);
    whichInputs.push_back(19);
    whichInputs.push_back(20);
    whichInputs.push_back(21);
    whichInputs.push_back(22);
    whichInputs.push_back(23);
    whichInputs.push_back(24);
    whichInputs.push_back(25);
    whichInputs.push_back(26);
    whichInputs.push_back(27);
    whichInputs.push_back(28);
    whichInputs.push_back(29);
    whichInputs.push_back(30);
    whichInputs.push_back(31);

    totalLayers = 2;
    maxNodes = 33;
    weights = new double **[totalLayers];
    for (int i = 0; i < totalLayers; ++i) {;
       weights[i] = new double*[maxNodes];
       for (int j = 0; j < maxNodes; ++j) {
           weights[i][j] = new double[maxNodes];
       }
    }
	//weights between input and hidden
    ///////////////////////////////////////////
    //model 3 - neural network
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
    whichInputs.push_back(8);
    whichInputs.push_back(9);
    whichInputs.push_back(10);
    whichInputs.push_back(11);
    whichInputs.push_back(12);
    whichInputs.push_back(13);
    whichInputs.push_back(14);
    whichInputs.push_back(15);
    whichInputs.push_back(16);
    whichInputs.push_back(17);
    whichInputs.push_back(18);
    whichInputs.push_back(19);
    whichInputs.push_back(20);
    whichInputs.push_back(21);
    whichInputs.push_back(22);
    whichInputs.push_back(23);
    whichInputs.push_back(24);
    whichInputs.push_back(25);
    whichInputs.push_back(26);
    whichInputs.push_back(27);
    whichInputs.push_back(28);
    whichInputs.push_back(29);
    whichInputs.push_back(30);
    whichInputs.push_back(31);

    totalLayers = 2;
    maxNodes = 33;
    weights = new double **[totalLayers];
    for (int i = 0; i < totalLayers; ++i) {;
       weights[i] = new double*[maxNodes];
       for (int j = 0; j < maxNodes; ++j) {
           weights[i][j] = new double[maxNodes];
       }
    }
	//weights between input and hidden
    ///////////////////////////////////////////
    //model 4 - neural network
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
    whichInputs.push_back(8);
    whichInputs.push_back(9);
    whichInputs.push_back(10);
    whichInputs.push_back(11);
    whichInputs.push_back(12);
    whichInputs.push_back(13);
    whichInputs.push_back(14);
    whichInputs.push_back(15);
    whichInputs.push_back(16);
    whichInputs.push_back(17);
    whichInputs.push_back(18);
    whichInputs.push_back(19);
    whichInputs.push_back(20);
    whichInputs.push_back(21);
    whichInputs.push_back(22);
    whichInputs.push_back(23);
    whichInputs.push_back(24);
    whichInputs.push_back(25);
    whichInputs.push_back(26);
    whichInputs.push_back(27);
    whichInputs.push_back(28);
    whichInputs.push_back(29);
    whichInputs.push_back(30);
    whichInputs.push_back(31);

    totalLayers = 2;
    maxNodes = 33;
    weights = new double **[totalLayers];
    for (int i = 0; i < totalLayers; ++i) {;
       weights[i] = new double*[maxNodes];
       for (int j = 0; j < maxNodes; ++j) {
           weights[i][j] = new double[maxNodes];
       }
    }
	//weights between input and hidden
    ///////////////////////////////////////////
    //model 5 - neural network
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
    whichInputs.push_back(8);
    whichInputs.push_back(9);
    whichInputs.push_back(10);
    whichInputs.push_back(11);
    whichInputs.push_back(12);
    whichInputs.push_back(13);
    whichInputs.push_back(14);
    whichInputs.push_back(15);
    whichInputs.push_back(16);
    whichInputs.push_back(17);
    whichInputs.push_back(18);
    whichInputs.push_back(19);
    whichInputs.push_back(20);
    whichInputs.push_back(21);
    whichInputs.push_back(22);
    whichInputs.push_back(23);
    whichInputs.push_back(24);
    whichInputs.push_back(25);
    whichInputs.push_back(26);
    whichInputs.push_back(27);
    whichInputs.push_back(28);
    whichInputs.push_back(29);
    whichInputs.push_back(30);
    whichInputs.push_back(31);

    totalLayers = 2;
    maxNodes = 33;
    weights = new double **[totalLayers];
    for (int i = 0; i < totalLayers; ++i) {;
       weights[i] = new double*[maxNodes];
       for (int j = 0; j < maxNodes; ++j) {
           weights[i][j] = new double[maxNodes];
       }
    }
	//weights between input and hidden
    ///////////////////////////////////////////
    //model 6 - neural network
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
    whichInputs.push_back(8);
    whichInputs.push_back(9);
    whichInputs.push_back(10);
    whichInputs.push_back(11);
    whichInputs.push_back(12);
    whichInputs.push_back(13);
    whichInputs.push_back(14);
    whichInputs.push_back(15);
    whichInputs.push_back(16);
    whichInputs.push_back(17);
    whichInputs.push_back(18);
    whichInputs.push_back(19);
    whichInputs.push_back(20);
    whichInputs.push_back(21);
    whichInputs.push_back(22);
    whichInputs.push_back(23);
    whichInputs.push_back(24);
    whichInputs.push_back(25);
    whichInputs.push_back(26);
    whichInputs.push_back(27);
    whichInputs.push_back(28);
    whichInputs.push_back(29);
    whichInputs.push_back(30);
    whichInputs.push_back(31);

    totalLayers = 2;
    maxNodes = 33;
    weights = new double **[totalLayers];
    for (int i = 0; i < totalLayers; ++i) {;
       weights[i] = new double*[maxNodes];
       for (int j = 0; j < maxNodes; ++j) {
           weights[i][j] = new double[maxNodes];
       }
    }
	//weights between input and hidden
    ///////////////////////////////////////////
    //model 7 - neural network
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
    whichInputs.push_back(8);
    whichInputs.push_back(9);
    whichInputs.push_back(10);
    whichInputs.push_back(11);
    whichInputs.push_back(12);
    whichInputs.push_back(13);
    whichInputs.push_back(14);
    whichInputs.push_back(15);
    whichInputs.push_back(16);
    whichInputs.push_back(17);
    whichInputs.push_back(18);
    whichInputs.push_back(19);
    whichInputs.push_back(20);
    whichInputs.push_back(21);
    whichInputs.push_back(22);
    whichInputs.push_back(23);
    whichInputs.push_back(24);
    whichInputs.push_back(25);
    whichInputs.push_back(26);
    whichInputs.push_back(27);
    whichInputs.push_back(28);
    whichInputs.push_back(29);
    whichInputs.push_back(30);
    whichInputs.push_back(31);

    totalLayers = 2;
    maxNodes = 33;
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