// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Merkle tree

contract Tree {
    bytes32[] public hashes;
    string[4] transactions = [
        "TX1: Tom -> Jeff",
        "TX2: Jeff -> Mary",
        "TX3: Peter -> Pamela",
        "TX3: Mary -> Mike"
    ];

    constructor() {
        // Loop for hashing given transactions, after creating a hash for each transaction row, it is added to a dynamic array hashes
        for (uint i = 0; i < transactions.length; i++) {
            hashes.push(makeHash(transactions[i]));
        }

        // Initial length of "leafs" equal to the number of transactions
        uint count = transactions.length;
        // Variable for offset
        uint offset = 0;

        /* Algorithm for creating hashes for the Merkle tree;
         * The hashes array sequentially includes hashes of the entire tree (H1   H2   H3   H4  H1-2   H3-4  ROOT)
         */
        while (count > 0) {
            for (uint i = 0; i < count - 1; i += 2) {
                hashes.push(
                    keccak256(
                        abi.encodePacked(
                            // from two adjacent hashes one common one is created (Н1-2)
                            hashes[offset + i],
                            hashes[offset + i + 1]
                        )
                    )
                );
            }
            offset += count;
            // Solidity does not support fractional type so if 0.5 is received, the value 0 will be assigned
            count = count / 2;
        }
    }

    // The function, given the proof array, after iterations, calculates the root hash for the selected transaction from transactions
    function verify(
        string memory transaction,
        uint index,
        bytes32 root,
        bytes32[] memory proof
    ) public pure returns (bool) {
        /*  Merkle tree
        ROOT

   H1-2      H3-4

 H1   H2   H3   H4

 TX1  TX2  TX3  TX4
*/

        // Hash of the transaction to be verified
        bytes32 hash = makeHash(transaction);
        for (uint i = 0; i < proof.length; i++) {
            bytes32 element = proof[i];
            if (index % 2 == 0) {
                // Creating a new hash for the even element and the next odd element (counting from 0)
                hash = keccak256(abi.encodePacked(hash, element));
            } else {
                // Creating a new hash for the odd and previous element (counting from 0)
                hash = keccak256(abi.encodePacked(element, hash));
            }
            // The next level of the tree is reduced by 2 times
            index = index / 2;
        }
        return hash == root;
    }

    function encode(
        string memory input
    )
        public
        pure
        returns (bytes memory /*byte array and encoding length unknown*/)
    {
        // Encoding function
        return abi.encodePacked(input);
    }

    function makeHash(string memory input) public pure returns (bytes32) {
        // Returns a hash with a known length
        return
            keccak256(
                // Encoded value
                encode(input)
            );
    }
}
