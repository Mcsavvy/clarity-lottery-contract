// Previous tests remain unchanged

Clarinet.test({
  name: "Test contract pause functionality",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('lottery', 'pause-contract', [], deployer.address),
      Tx.contractCall('lottery', 'buy-ticket', [types.uint(1)], wallet1.address)
    ]);
    
    assertEquals(block.receipts.length, 2);
    block.receipts[0].result.expectOk().expectBool(true);
    block.receipts[1].result.expectErr().expectUint(107);
  },
});

Clarinet.test({
  name: "Test withdrawal functionality",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('lottery', 'buy-ticket', [types.uint(1)], wallet1.address),
      Tx.contractCall('lottery', 'withdraw-balance', [types.uint(1000000)], deployer.address)
    ]);
    
    assertEquals(block.receipts.length, 2);
    block.receipts[0].result.expectOk().expectBool(true);
    block.receipts[1].result.expectOk().expectBool(true);
  },
});
