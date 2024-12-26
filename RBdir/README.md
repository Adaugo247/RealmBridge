# Cross-Realm Character Transfer System

This project implements a smart contract for a gasless character transfer system between different game realms. The contract is written in Clarity, a decidable smart contract language designed for use with the Stacks blockchain.

## Features

- Register character classes with associated realms and levels
- Execute cross-realm character transfers
- Verify signatures for secure transfers
- Manage portal fees for transfers
- Track used portals to prevent duplicate transfers

## Contract Overview

The smart contract includes the following main components:

1. **Storage**
   - UsedPortals: Tracks used portals to prevent duplicate transfers
   - GameCharacters: Stores character ownership and power levels
   - CharacterInfo: Stores character class, realm, and level information

2. **Constants**
   - Error codes for various failure scenarios
   - Maximum values for character and portal IDs

3. **Functions**
   - `register-character-class`: Register a new character class (owner-only)
   - `execute-realm-transfer`: Execute a cross-realm character transfer
   - `update-portal-fee`: Update the portal fee for transfers (owner-only)
   - `get-character-power`: Read-only function to get a character's power level

## Key Concepts

- **Gasless Transfers**: The system allows for gasless transfers of characters between realms.
- **Signature Verification**: Transfers require a valid signature to ensure security.
- **Portal System**: Transfers are executed through portals, with each portal usable only once per player.
- **Power Levels**: Characters have power levels that can be partially or fully transferred.

## Usage

To use this contract, deploy it to the Stacks blockchain and interact with it using the provided public functions. Ensure that you have the necessary permissions and valid signatures when executing transfers.

## Security Considerations

- The contract includes signature verification to prevent unauthorized transfers.
- Portals can only be used once per player to prevent replay attacks.
- Only the contract owner can register new character classes and update the portal fee.

## Future Improvements

- Implement actual secp256k1 signature verification (currently a placeholder).
- Add more detailed error messages for better user feedback.
- Implement additional features such as character merging or splitting.
