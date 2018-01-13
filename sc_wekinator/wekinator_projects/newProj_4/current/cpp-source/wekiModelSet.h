#ifndef modelSet_h
#define modelSet_h

#include <vector>
#include "baseModel.h"
#include "neuralNetwork.h"

class wekiModelSet {
public:
    wekiModelSet();
    ~wekiModelSet();
    void initModelSet();
    double* passInputToModels(double*);

private:
    std::vector<baseModel*> myModelSet;
};

#endif