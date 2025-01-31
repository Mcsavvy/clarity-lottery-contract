import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure that users can buy tickets",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('lottery', 'buy-ticket', [types.uint(1)], wallet1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectOk().expectBool(true);
  },
});

Clarinet.test({
  name: "Ensure that users cannot buy zero tickets",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('lottery', 'buy-ticket', [types.uint(0)], wallet1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectErr().expectUint(104);
  },
});

Clarinet.test({
  name: "Ensure that the contract owner can change the ticket price",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('lottery', 'change-ticket-price', [types.uint(2000000)], deployer.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectOk().expectBool(true);
  },
});

Clarinet.test({
  name: "Ensure that non-owners cannot change the ticket price",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('lottery', 'change-ticket-price', [types.uint(2000000)], wallet1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectErr().expectUint(100);
  },
});

Clarinet.test({
  name: "Ensure that the lottery draw requires minimum players",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('lottery', 'buy-ticket', [types.uint(1)], wallet1.address),
      Tx.contractCall('lottery', 'change-draw-interval', [types.uint(1)], deployer.address),
      Tx.contractCall('lottery', 'draw-lottery', [], deployer.address)
    ]);
    
    assertEquals(block.receipts.length, 3);
    assertEquals(block.height, 2);
    block.receipts[2].result.expectErr().expectUint(103);
  },
});

Clarinet.test({
  name: "Ensure that the lottery draw works correctly with minimum players",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    const wallet2 = accounts.get('wallet_2')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('lottery', 'buy-ticket', [types.uint(1)], wallet1.address),
      Tx.contractCall('lottery', 'buy-ticket', [types.uint(2)], wallet2.address),
      Tx.contractCall('lottery', 'change-draw-interval', [types.uint(1)], deployer.address),
      Tx.contractCall('lottery', 'draw-lottery', [], deployer.address)
    ]);
    
    assertEquals(block.receipts.length, 4);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectOk().expectBool(true);
    block.receipts[1].result.expectOk().expectBool(true);
    block.receipts[2].result.expectOk().expectBool(true);
    block.receipts[3].result.expectOk();
  },
});
