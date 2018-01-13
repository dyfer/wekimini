#ifndef baseModel_h
#define baseModel_h

class baseModel {
public:
    virtual double processInput(double*) = 0;
    virtual ~baseModel() {};
};

#endif