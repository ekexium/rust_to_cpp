#include "tikv_client.h"
#include <iostream>

int main() {
    auto client = tikv_client::TransactionClient({"127.0.0.1:2379"});
    auto txn = client.begin();
    txn.put("k1", "v2");
    if (std::string val; txn.get("k1", val)) {
        std::cout << val << std::endl;
    } else {
	std::cout << "key not found" << std::endl;
    }
    txn.commit();
    return 0;
}
