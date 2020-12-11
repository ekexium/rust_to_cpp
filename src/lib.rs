use anyhow::Result;
use futures::executor::block_on;
use std::pin::Pin;
use tikv_client::{self};

use cxx::{CxxString, CxxVector};

#[cxx::bridge]
mod ffi {
    #[namespace = "tikv_client_glue"]
    extern "Rust" {
        type TransactionClient;
        type Transaction;

        fn transaction_client_new(
            pd_endpoints: &CxxVector<CxxString>,
        ) -> Result<Box<TransactionClient>>;
        fn transaction_client_begin(client: &mut TransactionClient) -> Result<Box<Transaction>>;
        fn transaction_client_begin_pessimistic(client: &mut TransactionClient) -> Result<Box<Transaction>>;
        fn transaction_get(
            transaction: &Transaction,
            key: &CxxString,
            out: Pin<&mut CxxString>,
        ) -> Result<bool>;
        fn transaction_get_for_update(
            transaction: &mut Transaction,
            key: &CxxString,
            out: Pin<&mut CxxString>,
        ) -> Result<bool>;
        fn transaction_put(
            transaction: &mut Transaction,
            key: &CxxString,
            val: &CxxString,
        ) -> Result<()>;
        fn transaction_commit(transaction: &mut Transaction) -> Result<()>;
    }
}

#[repr(transparent)]
struct TransactionClient {
    inner: tikv_client::TransactionClient,
}
#[repr(transparent)]
struct Transaction {
    inner: tikv_client::Transaction,
}

fn transaction_client_new(pd_endpoints: &CxxVector<CxxString>) -> Result<Box<TransactionClient>> {
    let pd_endpoints = pd_endpoints
        .iter()
        .map(|str| str.to_str().map(ToOwned::to_owned))
        .collect::<std::result::Result<Vec<_>, _>>()?;

    Ok(Box::new(TransactionClient {
        inner: block_on(tikv_client::TransactionClient::new(pd_endpoints)).map_err(to_std_err)?,
    }))
}

fn transaction_client_begin(client: &mut TransactionClient) -> Result<Box<Transaction>> {
    Ok(Box::new(Transaction {
        inner: block_on(client.inner.begin()).map_err(to_std_err)?,
    }))
}
        
fn transaction_client_begin_pessimistic(client: &mut TransactionClient) -> Result<Box<Transaction>> {
    Ok(Box::new(Transaction {
        inner: block_on(client.inner.begin_pessimistic()).map_err(to_std_err)?,
    }))
}

fn transaction_get(
    transaction: &Transaction,
    key: &CxxString,
    out: Pin<&mut CxxString>,
) -> Result<bool> {
    match block_on(transaction.inner.get(key.as_bytes().to_vec())).map_err(to_std_err)? {
        Some(val) => {
            out.push_bytes(&val);
            Ok(true)
        }
        None => Ok(false),
    }
}

fn transaction_get_for_update(
    transaction: &mut Transaction,
    key: &CxxString,
    out: Pin<&mut CxxString>,
) -> Result<bool> {
    match block_on(transaction.inner.get_for_update(key.as_bytes().to_vec())).map_err(to_std_err)? {
        Some(val) => {
            out.push_bytes(&val);
            Ok(true)
        }
        None => Ok(false),
    }
}

fn transaction_put(transaction: &mut Transaction, key: &CxxString, val: &CxxString) -> Result<()> {
    block_on(
        transaction
            .inner
            .put(key.as_bytes().to_vec(), val.as_bytes().to_vec()),
    )
    .map_err(to_std_err)?;
    Ok(())
}

fn transaction_commit(transaction: &mut Transaction) -> Result<()> {
    block_on(transaction.inner.commit()).map_err(to_std_err)?;
    Ok(())
}

// TODO
fn to_std_err(err: impl std::string::ToString) -> anyhow::Error {
    anyhow::Error::msg(err.to_string())
}

