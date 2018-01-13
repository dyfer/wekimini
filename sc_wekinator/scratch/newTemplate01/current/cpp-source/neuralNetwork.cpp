#include <math.h>
#include <algorithm>
#include "neuralNetwork.h"

neuralNetwork::neuralNetwork(int num_inputs, 
                             std::vector<int> which_inputs,
                             int num_hidden_nodes,
                             double*** _weights,
                             double* w_hidden_output,
                             std::vector<double> in_max,
                             std::vector<double> in_min,
                             double out_max,
                             double out_min) {
	numInputs = num_inputs;
	whichInputs = which_inputs;
	numHiddenNodes = num_hidden_nodes;
	//input neurons, including bias
	inputNeurons = new double[numInputs + 1];
	for (int i=0; i < numInputs; ++i){
		inputNeurons[i] = 0;
	}
	inputNeurons[numInputs] = 1;

	//hidden neurons, including bias
	hiddenNeurons = new double[numHiddenNodes + 1];
	for (int i=0; i < numHiddenNodes; ++i){
		hiddenNeurons[i] = 0;
	}
	hiddenNeurons[numHiddenNodes] = 1;

	weights = _weights;
	wHiddenOutput = w_hidden_output;

	inRanges = new double[numInputs];
	inBases = new double[numInputs];

	for (int i = 0; i < numInputs; ++i) {
           double currentRange = (in_max[i] - in_min[i]) * 0.5;
           inRanges[i] = (currentRange == 0) ? 1.0 : currentRange;
           inBases[i] = (in_max[i] + in_min[i]) * 0.5;
	}

       outRange = (out_max - out_min) * 0.5;
       outBase = (out_max + out_min) * 0.5;
}

neuralNetwork::~neuralNetwork() {
	delete[] inputNeurons;
	delete[] hiddenNeurons;

	int maxNodes = std::max(numInputs, numHiddenNodes);
	for (int i=0; i <= numInputs; ++i) {
		for (int j=0; j <=maxNodes; ++j) {
                   delete[] weights[i][j];
		}
		delete[] weights[i];
	}
	delete[] weights;

	delete[] wHiddenOutput;
	delete[] inRanges;
	delete[] inBases;
}

inline double neuralNetwork::activationFunction(double x) {
	//sigmoid
       if (x < -45) { //from weka, to combat overflow
           x = 0;
       } else if (x > 45) {
           x = 1;
       } else {
           x = 1/(1 + exp(-x));
       }
       return x;
}

double neuralNetwork::processInput(double* inputVector) {
	double pattern[numInputs];
	for (int i = 0; i < numInputs; ++i) {
		pattern[i] = inputVector[whichInputs[i]];
	}

	//set input layer
	for (int i = 0; i < numInputs; ++i) {
		inputNeurons[i] = (pattern[i] - inBases[i]) / inRanges[i];
	}

	//calculate hidden layer
	for (int j = 0; j < numHiddenNodes; ++j) {
		hiddenNeurons[j] = 0;
		for (int i = 0; i <= numInputs; ++i) {
			hiddenNeurons[j] += inputNeurons[i] * weights[0][i][j];
		}
		hiddenNeurons[j] = activationFunction(hiddenNeurons[j]);
	}
	//calculate output
	double output = 0;
	for (int k=0; k <= numHiddenNodes; ++k){
           output += hiddenNeurons[k] * wHiddenOutput[k];
	}
       output = (output * outRange) + outBase;
	return output;
}

