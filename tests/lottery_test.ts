// Previous tests remain unchanged

Clarinet.test({
  name: "Ensure users cannot exceed max tickets per player limit",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('lottery', 'buy-ticket', [types.uint(101)], wallet1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectErr().expectUint(105);
  },
});

Clarinet.test({
  name: "Test invalid participant handling in random winner selection",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('lottery', 'draw-lottery', [], wallet1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectErr().expectUint(106);
  },
});
