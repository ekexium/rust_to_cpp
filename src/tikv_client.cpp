#include "tikv_client.h"

using namespace std;
using ::rust::cxxbridge1::Box;

namespace tikv_client {

TransactionClient::TransactionClient(const std::vector<std::string> &pd_endpoints):
    _client(tikv_client_glue::transaction_client_new(pd_endpoints)) {}

Transaction TransactionClient::begin() {
    return Transaction(transaction_client_begin(*_client));
}

Transaction::Transaction(Box<tikv_client_glue::Transaction> txn) : _txn(std::move(txn)) {}

bool Transaction::get(const std::string &key, std::string &out) {
    return transaction_get(*_txn, key, out);
}

void Transaction::put(const string &key, const string &val) {
    transaction_put(*_txn, key, val);
}

void Transaction::commit() {
    transaction_commit(*_txn);
}

}
