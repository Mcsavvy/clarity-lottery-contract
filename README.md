# Stacks Lottery Contract

This is a Clarity smart contract that implements a lottery system with the following features:

1. Random number generation
2. Multiple ticket purchases
3. Automatic prize distribution
4. Time-based draws
5. Minimum players requirement

## Features

- Users can buy multiple tickets
- The contract owner can change the ticket price and draw interval
- Lottery draws are based on a time interval (block height)
- Winners are selected randomly
- Prize is automatically distributed to the winner
- Minimum number of players required for a draw
- Input validation for ticket purchases

## Functions

- `buy-ticket`: Allows users to purchase lottery tickets
- `draw-lottery`: Initiates the lottery draw and distributes the prize
- `change-ticket-price`: Allows the owner to change the ticket price
- `change-draw-interval`: Allows the owner to change the draw interval
- `change-min-players`: Allows the owner to change the minimum required players
- `get-ticket-price`: Returns the current ticket price
- `get-lottery-balance`: Returns the current lottery balance
- `get-tickets`: Returns the number of tickets owned by a participant
- `get-last-winner`: Returns the winner of a specific lottery draw
- `get-min-players`: Returns the minimum required players for a draw

## Testing

The contract includes a test file with several unit tests to ensure proper functionality, including:
- Ticket purchase validation
- Minimum players requirement
- Owner-only functions
- Lottery draw mechanics

## Recent Enhancements

1. Added minimum players requirement to prevent draws with insufficient participation
2. Added input validation for ticket purchases to prevent zero-ticket purchases
3. Added new function to allow owner to configure minimum players requirement
4. Enhanced test coverage for new features
