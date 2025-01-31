# Stacks Lottery Contract

This is a Clarity smart contract that implements a lottery system with the following features:

1. Random number generation
2. Multiple ticket purchases with maximum limit per player
3. Automatic prize distribution
4. Time-based draws
5. Minimum players requirement

## Features

- Users can buy multiple tickets (up to a maximum limit)
- The contract owner can change the ticket price and draw interval
- Lottery draws are based on a time interval (block height)
- Winners are selected randomly
- Prize is automatically distributed to the winner
- Minimum number of players required for a draw
- Input validation for ticket purchases
- Maximum tickets per player to prevent manipulation

## Functions

[Previous function list remains unchanged]

## Testing

The contract includes a test file with several unit tests to ensure proper functionality, including:
- Ticket purchase validation
- Minimum players requirement
- Owner-only functions
- Lottery draw mechanics
- Maximum tickets per player validation

## Recent Enhancements

1. Added maximum tickets per player limit to prevent lottery manipulation
2. Added input validation for ticket purchases to prevent zero-ticket purchases
3. Added new function to allow owner to configure minimum players requirement
4. Enhanced test coverage for new features
