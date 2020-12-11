#ifndef _TIKV_CLIENT_H_
#define _TIKV_CLIENT_H_ 

#include "tikv_client_glue.h"
#include <iostream>

using ::rust::cxxbridge1::Box;

namespace tikv_client {

class Transaction {
public:
    Transaction(Box<tikv_client_glue::Transaction> txn);
    bool get(const std::string &key, std::string &out);
    void put(const std::string &key, const std::string &val);
    void commit();
private:
    Box<tikv_client_glue::Transaction> _txn;
};

class TransactionClient {
public:
    TransactionClient(const std::vector<std::string> &pd_endpoints);
    Transaction begin();
private:
    Box<tikv_client_glue::TransactionClient> _client;
};

}

#endif //_TIKV_CLIENT_H_
