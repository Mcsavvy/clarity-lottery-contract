# Stacks Lottery Contract

This is a Clarity smart contract that implements a lottery system with the following features:

1. Random number generation
2. Multiple ticket purchases
3. Automatic prize distribution
4. Time-based draws

## Features

- Users can buy multiple tickets
- The contract owner can change the ticket price and draw interval
- Lottery draws are based on a time interval (block height)
- Winners are selected randomly
- Prize is automatically distributed to the winner

## Functions

- `buy-ticket`: Allows users to purchase lottery tickets
- `draw-lottery`: Initiates the lottery draw and distributes the prize
- `change-ticket-price`: Allows the owner to change the ticket price
- `change-draw-interval`: Allows the owner to change the draw interval
- `get-ticket-price`: Returns the current ticket price
- `get-lottery-balance`: Returns the current lottery balance
- `get-tickets`: Returns the number of tickets owned by a participant
- `get-last-winner`: Returns the winner of a specific lottery draw

## Testing

The contract includes a test file with several unit tests to ensure proper functionality.

