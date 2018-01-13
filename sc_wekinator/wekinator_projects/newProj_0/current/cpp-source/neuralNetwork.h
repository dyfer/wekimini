#ifndef neuralNetwork_h
#define neuralNetwork_h

#include <vector>
#include "baseModel.h"

class neuralNetwork : public baseModel {

public:

	neuralNetwork(int, std::vector<int>, int, double***, double*, std::vector<double>, std::vector<double>, double, double);
	~neuralNetwork();

	double processInput(double*);

private:

	int numInputs;
    std::vector<int> whichInputs;

	int numHiddenNodes;

	double* inputNeurons;
	double* hiddenNeurons;
	double*** weights;
	double* wHiddenOutput;

    double* inRanges;
    double* inBases;
    double outRange;
    double outBase;

	inline double activationFunction(double);
};

#endif

